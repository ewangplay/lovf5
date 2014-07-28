package WindowManager;

use strict;
use Glib qw/TRUE FALSE/;
use Common;

sub new {
	my ($class, $app, $view) = @_;
	my $this = {};
	$this->{'app'} = $app;
	$this->{'view'} = $view;
	$this->{'start_minimized'} = FALSE;
	bless $this, $class;
	return $this;
}

sub init {
	my $this = shift;
	my $app = $this->{'app'};
	my $view = $this->{'view'};

	my $key_file = Glib::KeyFile->new;
        
	# load global options
        my $width = 500;
        my $height = 700;
        my $auto_update = FALSE;
	my $global_profile = get_global_profile();
	if (-e $global_profile) {
		$key_file->load_from_file($global_profile, 'none');

		$position_x = $key_file->get_integer('WindowGeometry', 'WindowPositionX');
		$position_y = $key_file->get_integer('WindowGeometry', 'WindowPositionY');
		$width = $key_file->get_integer('WindowGeometry', 'WindowSizeX');
		$height = $key_file->get_integer('WindowGeometry', 'WindowSizeY');
                $this->{'start_minimized'} = $key_file->get_boolean('Generic', 'StartMinimized');
                $auto_update = $key_file->get_boolean('Generic', 'AutoUpdate');
		$current_view_index = $key_file->get_integer('Generic', 'ViewIndex');	# global
		$update_frequency = $key_file->get_integer('Generic', 'UpdateFrequency'); #global
		$background_red = $key_file->get_integer('Theme', 'Background_red'); #global
		$background_green = $key_file->get_integer('Theme', 'Background_green'); #global
		$background_blue = $key_file->get_integer('Theme', 'Background_blue'); #global
		$foreground_red = $key_file->get_integer('Theme', 'Foreground_red'); #global
		$foreground_green = $key_file->get_integer('Theme', 'Foreground_green'); #global
		$foreground_blue = $key_file->get_integer('Theme', 'Foreground_blue'); #global
		$status_fontname = $key_file->get_string('Theme', 'Fontname'); #global
	}

	# load auto-startup options
	my $auto_startup = FALSE;
	my $autostart_profile = get_autostart_profile();
	if (-e $autostart_profile) {
		$key_file->load_from_file($autostart_profile, 'none');

		$auto_startup = $key_file->get_boolean('Desktop Entry', 'X-GNOME-Autostart-enabled');
	}

        # initialize the auto-fresh check button
        my $checkbutton_auto_refresh = $app->get_widget('checkbutton_auto_refresh');
        $checkbutton_auto_refresh->set_active($auto_update);
        
	# initialize the start-minimized check button
	my $checkbutton_start_minimized = $app->get_widget('checkbutton_start_minimized');
	$checkbutton_start_minimized->set_active($this->{'start_minimized'});

	# initialize the auto-startup check button
	my $checkbutton_auto_startup = $app->get_widget('checkbutton_auto_startup');
	$checkbutton_auto_startup->set_active($auto_startup);

	# initialize the auto update frequency combo box
	my $combobox_update_freq = $app->get_widget('combobox_update_freq');
	$combobox_update_freq->set_active($update_frequency / 60 / 5);

	# initialize the link remove button
	my $linkbutton_remove_link = $app->get_widget('linkbutton_remove_link');
	$linkbutton_remove_link->set_sensitive(FALSE);

	# initialize the status notebook
	my $notebook_statuses = $app->get_widget('notebook_statuses');
	$notebook_statuses->set_current_page($current_view_index);

	# initialize the friends status tree view
	my $treeview_friends_status = $app->get_widget('treeview_friends_status');
	$treeview_friends_status->set('enable-grid-lines' => 'both');
	$treeview_friends_status->set_search_column(0);	#username column
	$treeview_friends_status->set_search_equal_func(\&search_equal_func);

	# initialize my status tree view
	my $treeview_my_status = $app->get_widget('treeview_my_status');
	$treeview_my_status->set('enable-grid-lines' => 'both');
	$treeview_my_status->set_search_column(0);	#username column
	$treeview_my_status->set_search_equal_func(\&search_equal_func);

	# initialize the public  status tree view
	my $treeview_public_status = $app->get_widget('treeview_public_status');
	$treeview_public_status->set('enable-grid-lines' => 'both');
	$treeview_public_status->set_search_column(0);	#username column
	$treeview_public_status->set_search_equal_func(\&search_equal_func);

	# initialize the background colorbutton and set the background color
	my $background_color = Gtk2::Gdk::Color->new(
		$background_red, 
		$background_green, 
		$background_blue);
	my $colorbutton_background = $app->get_widget('colorbutton_status_background');
	$colorbutton_background->set_color($background_color);
	$view->set_background_color($background_color);

	# initialize the foreground colorbutton and set the foreground color
	my $foreground_color = Gtk2::Gdk::Color->new(
		$foreground_red, 
		$foreground_green, 
		$foreground_blue);
	my $colorbutton_foreground = $app->get_widget('colorbutton_status_foreground');
	$colorbutton_foreground->set_color($foreground_color);
	$view->set_foreground_color($foreground_color);

	# initialize the fontbutton and set the status font name
	my $fontbutton = $app->get_widget('fontbutton_status_font');
	$fontbutton->set_font_name($status_fontname);
	$view->set_status_font($status_fontname);

	# initialize the mian window
	my $window = $app->get_widget('main_window');
	$window->resize($width, $height);
	$window->move($position_x, $position_y);
	$window->signal_connect('delete_event', \&change_window_status, $app);
}

sub show {
	my $this = shift;
	my $app = $this->{'app'};

	# show the main window
	my $window = $app->get_widget('main_window');
	if (!$this->{'start_minimized'}) {
		$window->show;
	}
}

1; # terminate this package with 1
