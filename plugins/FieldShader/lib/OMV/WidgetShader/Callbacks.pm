package OMV::WidgetShader::Callbacks;
# WidgetShader (C) 2012 Piroli YUKARINOMIYA (Open MagicVox.net)
# This program is distributed under the terms of the GNU Lesser General Public License, version 3.
# $Id$

use MT;
use MT::PluginData;

sub instance { MT->component(__PACKAGE__ =~ /^(\w+::\w+)/g); }

### MT::App::CMS::template_source.edit_entry
sub template_source_edit_entry {
    my ($cb, $app, $tmpl) = @_;

    # JavaScript
    chomp(my $old = <<'MTMLHEREDOC');
<mt:include name="include/footer.tmpl"
MTMLHEREDOC
    $old = quotemeta $old;

    my $new = <<'MTMLHEREDOC';
<mt:setvarblock name="jq_js_include" append="1">
    // Toggle the shade with double clicking
    jQuery('div.widget-header').dblclick (function () {
        // Save the preference with ajax
        var wdgt = jQuery(this).parent('.widget');
        var param = {
            '__mode'        : 'save_widget_shader_prefs',
            '_type'         : '<mt:var name="object_type">',
            'blog_id'       : <mt:var name="blog_id">,
            'widget'        : wdgt.attr('id'),
            'shade'         : wdgt.hasClass('widget-shaded'),
            'magic_token'   : '<mt:var name="magic_token">'
        };
        jQuery.post('<mt:var name="script_url">', param);

        // Animate the opening/closing style
        var chld = wdgt.children('.widget-content');
        wdgt.hasClass('widget-shaded')
            ? chld.slideDown(300, function () { wdgt.removeClass('widget-shaded'); })
            : chld.slideUp(300, function () { wdgt.addClass('widget-shaded'); });
    });
<mt:if shaded_widgets>
    // Shade the widgets<mt:loop shaded_widgets>
    jQuery('#<mt:var __value__>').addClass('widget-shaded');</mt:loop></mt:if>
</mt:setvarblock>
MTMLHEREDOC
    $$tmpl =~ s/($old)/$new$1/;

    # Style
    chomp($old = <<'MTMLHEREDOC');
<mt:include name="include/header.tmpl"
MTMLHEREDOC
    $old = quotemeta $old;

    $new = <<'MTMLHEREDOC';
<mt:setvarblock name="html_head" append="1">
<style type="text/css">
div.widget .widget-header {
    cursor: pointer;
}

div.widget.widget-shaded .widget-header {
    margin-bottom: 0px;
}

div.widget.widget-shaded .widget-content {
    display: none;
}
div.widget.widget-shaded .widget-label {
    background: url("<mt:var static_uri>images/arrow/spinner-right.png") left center no-repeat;
}
div.widget .widget-label {
    padding-left: 16px;
    background: url("<mt:var static_uri>images/arrow/spinner-bottom.png") left center no-repeat;
}
</style>
</mt:setvarblock>
MTMLHEREDOC
    $$tmpl =~ s/($old)/$new$1/;
}

### MT::App::CMS::template_param.edit_entry
sub template_param_edit_entry {
    my ($cb, $app, $param) = @_;

    my $user = $app->user
        or return;
    my $blog = $app->blog
        or return;

    my %params = (
        author_id =>    $user->id,
        blog_id =>      $blog->id,
        type =>         $param->{object_type},
    );
    my $key = join ',', map { "$_:$params{$_}" } sort keys %params;
    my $pd = MT::PluginData->load({
        plugin => &instance->id, key => $key,
    })  or return;
    my $data = $pd->data || {};

    my @shaded_widgets = grep {
        defined $data->{$_} && !$data->{$_};
    } keys %$data;
    $param->{shaded_widgets} = \@shaded_widgets if @shaded_widgets;
}

1;