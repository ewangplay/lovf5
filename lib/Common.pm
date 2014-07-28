package Common;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(
	search_equal_func
	quit_application
	change_window_status
	encrypt
	decrypt
	get_profile_dir 
	get_global_profile 
	get_login_profile 
	get_password_profile
	get_autostart_profile
	get_prefix_dir
	get_cipher_key

	$login_success
	$remember_name
	$remember_password
	$auto_login
	$current_view_index
	$update_frequency
	$background_red
	$background_green
	$background_blue
	$foreground_red
	$foreground_green
	$foreground_blue
	$status_fontname
	$position_x
	$position_y

	$API_KEY
	$BACKGROUND_RED_DEFAULT
	$BACKGROUND_GREEN_DEFAULT
	$BACKGROUND_BLUE_DEFAULT
	$FOREGROUND_RED_DEFAULT
	$FOREGROUND_GREEN_DEFAULT
	$FOREGROUND_BLUE_DEFAULT
	$FONTNAME_DEFAULT
	$FRIENDS_STATUS_VIEW_INDEX
	$MY_STATUS_VIEW_INDEX
	$PUBLIC_STATUS_VIEW_INDEX
	);

use strict;
use Glib qw(TRUE FALSE);
use FindBin qw($Bin);
use Global;

# global constant
our $API_KEY = '84010F88F2EA60D8';
our $BACKGROUND_RED_DEFAULT = 26214;
our $BACKGROUND_GREEN_DEFAULT = 39321;
our $BACKGROUND_BLUE_DEFAULT = 52428;
our $FOREGROUND_RED_DEFAULT = 0;
our $FOREGROUND_GREEN_DEFAULT = 0;
our $FOREGROUND_BLUE_DEFAULT = 0;
our $FONTNAME_DEFAULT = 'Sans 12';
our $FRIENDS_STATUS_VIEW_INDEX = 0;
our $MY_STATUS_VIEW_INDEX = 1;
our $PUBLIC_STATUS_VIEW_INDEX = 2;

# global variant
our $login_success;
our $remember_name;
our $remember_password;
our $auto_login;
our $current_view_index;
our $update_frequency;
our $background_red;
our $background_green;
our $background_blue;
our $foreground_red;
our $foreground_green;
our $foreground_blue;
our $status_fontname;
our ($position_x, $position_y);

# global functions
sub search_equal_func {
	my ($model, $column, $key, $iter) = @_;
	my $username = $model->get($iter, 1);	#username column in tree model
	if ($username =~ /^$key/) {
		return FALSE;
	}
	return TRUE;
}

sub quit_application {
	my $app = $_[-1]; # get the last param: glade xml instance

	my $key_file = Glib::KeyFile->new;

	# load the generic configure
	my $global_profile = get_global_profile();
	if (-e $global_profile) {
		$key_file->load_from_file($global_profile, 'none');
	}

	# set the window geometry
	my $main_window = $app->get_widget('main_window');
	my ($width, $height) = $main_window->get_size;
	my ($pos_x, $pos_y) = $main_window->get_position;
	$key_file->set_integer('WindowGeometry', 'WindowPositionX', $pos_x);
	$key_file->set_integer('WindowGeometry', 'WindowPositionY', $pos_y);
	$key_file->set_integer('WindowGeometry', 'WindowSizeX', $width);
	$key_file->set_integer('WindowGeometry', 'WindowSizeY', $height);

	# set the start-minimized option
	my $checkbutton_start_minimized = $app->get_widget('checkbutton_start_minimized');
	$key_file->set_boolean('Generic', 'StartMinimized', $checkbutton_start_minimized->get_active);

	# set the auto-update option
	my $checkbutton_auto_refresh = $app->get_widget('checkbutton_auto_refresh');
	$key_file->set_boolean('Generic', 'AutoUpdate', $checkbutton_auto_refresh->get_active);
	
	# set the current view index
	$key_file->set_integer('Generic', 'ViewIndex', $current_view_index);

	# set the update frequency
	$key_file->set_integer('Generic', 'UpdateFrequency', $update_frequency);

	# set the color theme
	$key_file->set_integer('Theme', 'Background_red', $background_red);
	$key_file->set_integer('Theme', 'Background_green', $background_green);
	$key_file->set_integer('Theme', 'Background_blue', $background_blue);
	$key_file->set_integer('Theme', 'Foreground_red', $foreground_red);
	$key_file->set_integer('Theme', 'Foreground_green', $foreground_green);
	$key_file->set_integer('Theme', 'Foreground_blue', $foreground_blue);

	# set the font name
	$key_file->set_string('Theme', 'Fontname', $status_fontname);

	# save the options to file
	my $key_string = $key_file->to_data;
	FileSetContents($global_profile, $key_string);

	$key_file = Glib::KeyFile->new;

	# load the auto-startup configure
	my $autostart_profile = get_autostart_profile();
	if (-e $autostart_profile) {
		$key_file->load_from_file($autostart_profile, 'none');
	}

	# set the auto-statup option
	my $checkbutton_auto_startup = $app->get_widget('checkbutton_auto_startup');
	$key_file->set_boolean('Desktop Entry', 'X-GNOME-Autostart-enabled', $checkbutton_auto_startup->get_active);

	# save the auto-startup options to file
	$key_string = $key_file->to_data;
	FileSetContents($autostart_profile, $key_string);

	# quit application
	Gtk2->main_quit;
}

sub change_window_status {
	my $app = $_[-1]; 	# get the last param: glade xml instance
	my $window = $app->get_widget('main_window');

	if ($window->get('visible')) {
		($position_x, $position_y) = $window->get_position;
		$window->hide;
	}
	else {
		$window->show;
		$window->move($position_x, $position_y);
	}

	return TRUE;
}

sub encrypt {
	my $plain_text = shift;
	my $encrypt_text;
	my $cipher = new Crypt::Blowfish(get_cipher_key());

	while(my $p = substr($plain_text, 0, 8)) {
		my $len = length($p);
		if ($len % 8 != 0) {
			$p .= "\000"x( 8 - $len % 8); 
		}   
		$encrypt_text .= $cipher->encrypt($p);
		if (length($plain_text) > 8) {
			$plain_text = substr($plain_text, 8)  
		} else {
			last;
		}   
	}

	return $encrypt_text;
}

sub decrypt {
	my $encrypt_text = shift;
	my $plain_text;
	my $cipher = new Crypt::Blowfish(get_cipher_key());

	while(my $p = substr($encrypt_text, 0, 8)) {
		my $len = length($p);
		if ($len % 8 != 0) {
			$p .= "\000"x( 8 - $len % 8); 
		}   
		$plain_text .= $cipher->decrypt($p);
		if (length($encrypt_text) > 8) {
			$encrypt_text = substr($encrypt_text, 8)  
		} else {
			last;
		}   
	}

	return $plain_text;
}

sub get_profile_dir {
	my $profile_dir = $ENV{'HOME'} . "/.lovf5";
	return $profile_dir;
}

sub get_global_profile {
	my $global_profile = $ENV{'HOME'} . "/.lovf5/global.conf";
	return $global_profile;
}

sub get_login_profile {
	my $login_profile = $ENV{'HOME'} . "/.lovf5/login.conf";
	return $login_profile;
}

sub get_password_profile {
	my $password_profile = $ENV{'HOME'} . "/.lovf5/password.encrypt";
	return $password_profile;
}

sub get_autostart_profile {
	my $autostart_profile = $ENV{'HOME'} . "/.config/autostart/lovf5.desktop";
	return $autostart_profile;
}

sub get_prefix_dir {
	return "$Bin";
}

sub get_cipher_key {
	my $key = $API_KEY;
	if (length($key) % 8 != 0) {
		$key .= "\000"x(8 - length($key) % 8); 
	}
	return $key;
}

1; #terminate this package with 1
