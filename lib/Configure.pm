package Configure;
require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw(initialize_config);

use strict;
use Glib qw(TRUE FALSE);
use Common;
use Global;

sub initialize_config {
	# if the profile path is not exist, create it.
	my $profile_path = get_profile_dir();
	if(not -d $profile_path) {
		if (!mkdir($profile_path, 0600)) {
			return FALSE;
		}
	}

	# if the global profile is not exist, create it and 
	# set default config value
	my $global_profile = get_global_profile();
	if(not -e $global_profile) {
		my $key_file = Glib::KeyFile->new;
		$key_file->set_integer('WindowGeometry', 'WindowPositionX', 0);
		$key_file->set_integer('WindowGeometry', 'WindowPositionY', 0);
		$key_file->set_integer('WindowGeometry', 'WindowSizeX', 600);
		$key_file->set_integer('WindowGeometry', 'WindowSizeY', 700);
		$key_file->set_boolean('Generic', 'StartMinimized', FALSE);
                $key_file->set_boolean('Generic', 'AutoUpdate', FALSE);
		$key_file->set_integer('Generic', 'ViewIndex', 0);
		$key_file->set_integer('Generic', 'UpdateFrequency', 300);
		$key_file->set_integer('Theme', 'Background_red', $BACKGROUND_RED_DEFAULT);
		$key_file->set_integer('Theme', 'Background_green', $BACKGROUND_GREEN_DEFAULT);
		$key_file->set_integer('Theme', 'Background_blue', $BACKGROUND_BLUE_DEFAULT);
		$key_file->set_integer('Theme', 'Foreground_red', $FOREGROUND_RED_DEFAULT);
		$key_file->set_integer('Theme', 'Foreground_green', $FOREGROUND_GREEN_DEFAULT);
		$key_file->set_integer('Theme', 'Foreground_blue', $FOREGROUND_BLUE_DEFAULT);
		$key_file->set_string('Theme', 'Fontname', $FONTNAME_DEFAULT);

		my $key_string = $key_file->to_data;

                FileSetContents($global_profile, $key_string);
	}

	# if the autostart profile is not exist, create it and 
	# set default configure
	my $autostart_profile = get_autostart_profile();
	if(not -e $autostart_profile) {
		my $key_file = Glib::KeyFile->new;
		$key_file->set_string('Desktop Entry', 'Type', 'Application');
		$key_file->set_string('Desktop Entry', 'Encoding', 'UTF-8');
		$key_file->set_string('Desktop Entry', 'Version', '1.0');
		$key_file->set_string('Desktop Entry', 'Name', 'lovf5');
		$key_file->set_string('Desktop Entry', 'Exec', 'lovf5');
		$key_file->set_boolean('Desktop Entry', 'X-GNOME-Autostart-enabled', FALSE);

		my $key_string = $key_file->to_data;

		FileSetContents($autostart_profile, $key_string);
	}

	return TRUE;
}

1; #terminate this package with 1
