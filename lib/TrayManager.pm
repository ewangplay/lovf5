package TrayManager;

use strict;
use Encode qw/decode/;
use Common;

sub new {
	my ($class, $app) = @_;
	my $this = {};
	$this->{'app'} = $app;
	$this->{'status_icon'} = Gtk2::StatusIcon->new;
	$this->{'position_x'} = 0;
	$this->{'position_y'} = 0;
	bless $this, $class;
	return $this;
}

sub init {
	my $this = shift;
	my $app = $this->{'app'};
	my $status_icon = $this->{'status_icon'};

	$status_icon->set_from_file(get_prefix_dir() . '/image/lovf5.png');
	$status_icon->set_tooltip(decode('utf8', 'Follow5客户端'));
	$status_icon->signal_connect('activate' => \&change_window_status, $app);
	$status_icon->signal_connect('popup-menu' => \&status_menu, $app);
}

sub status_menu {
	my ($status_icon, $button, $activate_time, $app) = @_;

	my $menu = Gtk2::Menu->new;
	
	my $quit_item = Gtk2::ImageMenuItem->new_from_stock('gtk-quit');
	$quit_item->signal_connect('activate', \&quit_application, $app);

	$menu->append($quit_item);

	$menu->show_all;

	$menu->popup(
		undef,
		undef,
		\&Gtk2::StatusIcon::position_menu,
		$status_icon,
		$button,
		$activate_time
	);
}

1; #terminate this package with 1
