package OMV::FieldShader::Methods;
# FieldShader (C) 2012 Piroli YUKARINOMIYA (Open MagicVox.net)
# This program is distributed under the terms of the GNU Lesser General Public License, version 3.
# $Id$

use MT;
use MT::PluginData;

sub instance { MT->component(__PACKAGE__ =~ /^(\w+::\w+)/g); }

### save_filed_shader_prefs
sub save_filed_shader_prefs {
    my ($app) = @_;

    if ($app->validate_magic
            && defined(my $user = $app->user)
            && defined(my $blog = $app->blog)
            && defined(my $_type = $app->param ('_type'))
            && defined(my $field = $app->param ('field'))
            && defined(my $shade = $app->param ('shade'))
    ) {
        my %params = (
            author_id =>    $user->id,
            blog_id =>      $blog->id,
            type =>         $_type,
        );
        my $key = join ',', map { "$_:$params{$_}" } sort keys %params;
        my $pd = MT::PluginData->get_by_key ({
            plugin => &instance->id, key => $key,
        });
        my $data = $pd->data || {};
        $data->{$field} = $shade eq 'true' ? 1 : 0;
        $pd->data($data);
        $pd->save;

        $app->send_http_header('text/json');
        return 'true';
    }
    $app->send_http_header('text/json');
    return 'false';
}

1;