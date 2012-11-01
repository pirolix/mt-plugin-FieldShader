package MT::Plugin::Editing::OMV::WidgetShader;
# WidgetShader (C) 2012 Piroli YUKARINOMIYA (Open MagicVox.net)
# This program is distributed under the terms of the GNU Lesser General Public License, version 3.
# $Id$

use strict;
use MT 5.1;

use vars qw( $VENDOR $MYNAME $FULLNAME $VERSION );
$FULLNAME = join '::',
        (($VENDOR, $MYNAME) = (split /::/, __PACKAGE__)[-2, -1]);
(my $revision = '$Rev$') =~ s/\D//g;
$VERSION = 'v0.10'. ($revision ? ".$revision" : '');

use base qw( MT::Plugin );
my $plugin = __PACKAGE__->new ({
    id => $FULLNAME,
    key => $FULLNAME,
    name => $MYNAME,
    version => $VERSION,
    author_name => 'Open MagicVox.net',
    author_link => 'http://www.magicvox.net/',
    plugin_link => 'http://www.magicvox.net/archive/2012/11011905/', # Blog
    doc_link => 'http://lab.magicvox.net/trac/mt-plugins/wiki/FieldShader', # tracWiki
    description => <<'HTMLHEREDOC',
<__trans phrase="Enable to toggle shading of the widgets.">
HTMLHEREDOC
    l10n_class => "${FULLNAME}::L10N",
    registry => {
        callbacks => {
            # ブログ記事/ウェブページ編集画面
            'MT::App::CMS::template_source.edit_entry' => "${FULLNAME}::Callbacks::template_source_edit_entry",
            'MT::App::CMS::template_param.edit_entry' => "${FULLNAME}::Callbacks::template_param_edit_entry",
            # テンプレート編集画面
            'MT::App::CMS::template_source.edit_template' => "${FULLNAME}::Callbacks::template_source_edit_entry",
            'MT::App::CMS::template_param.edit_template' => "${FULLNAME}::Callbacks::template_param_edit_entry",
        },
        applications => {
            cms => {
                methods => {
                    save_widget_shader_prefs => "${FULLNAME}::Methods::save_widget_shader_prefs",
                },
            },
        },
    },
});
MT->add_plugin ($plugin);

sub instance { $plugin; }

1;