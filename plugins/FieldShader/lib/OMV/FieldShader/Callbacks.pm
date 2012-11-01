package OMV::FieldShader::Callbacks;
# FieldShader (C) 2012 Piroli YUKARINOMIYA (Open MagicVox.net)
# This program is distributed under the terms of the GNU Lesser General Public License, version 3.
# $Id$

use MT;
use MT::PluginData;

sub instance { MT->component(__PACKAGE__ =~ /^(\w+::\w+)/g); }

### MT::App::CMS::template_source.edit_entry
sub template_source_edit_entry {
    my ($cb, $app, $tmpl) = @_;

    # JavaScript
    my $old = quotemeta (<<'MTMLHEREDOC');
<mt:include name="include/footer.tmpl" id="footer_include">
MTMLHEREDOC
    my $new = <<'MTMLHEREDOC';
<mt:setvarblock name="jq_js_include" append="1">
    // Toggle the shade with double clicking
    jQuery('div.field-top-label').dblclick (function () {
        // Save the preference with Ajax
        var self = jQuery(this);
        var param = {
            '__mode'        : 'save_filed_shader_prefs',
            '_type'         : '<mt:var name="object_type">',
            'blog_id'       : <mt:var name="blog_id">,
            'field'         : self.attr('id'),
            'shade'         : self.hasClass('field-shaded'),
            'magic_token'   : '<mt:var name="magic_token">'
        };
        jQuery.post('<mt:var name="script_url">', param);

        // Animate the opening/closing style
        var chld = self.children('div.field-content');
        self.hasClass('field-shaded')
            ? chld.slideDown(300, function () { self.removeClass('field-shaded'); })
            : chld.slideUp(300, function () { self.addClass('field-shaded'); });
    });
<mt:if shaded_fiedls>
    // Shade the fields<mt:loop shaded_fiedls>
    jQuery('#<mt:var __value__>').addClass('field-shaded');</mt:loop></mt:if>
</mt:setvarblock>
MTMLHEREDOC
    $$tmpl =~ s/($old)/$new$1/;

    # Style
    $old = quotemeta (<<'MTMLHEREDOC');
<mt:include name="include/header.tmpl" id="header_include">
MTMLHEREDOC
    $new = <<'MTMLHEREDOC';
<mt:setvarblock name="html_head" append="1">
<style type="text/css">
div.field.sort-enabled .field-header label {
    background: url("<mt:var static_uri>images/arrow/spinner-bottom.png") left center no-repeat;
    cursor: pointer;
    padding-left: 16px;
}
div.field.sort-enabled.field-shaded .field-header {
    margin-bottom: 0 !important;
}
div.field.sort-enabled.field-shaded .field-header label {
    background: url("<mt:var static_uri>images/arrow/spinner-right.png") left center no-repeat;
}
div.field.sort-enabled.field-shaded .field-content {
    display: none;
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

    my @shaded_fiedls = grep {
        defined $data->{$_} && !$data->{$_};
    } keys %$data;
    $param->{shaded_fiedls} = \@shaded_fiedls if @shaded_fiedls;
}

1;