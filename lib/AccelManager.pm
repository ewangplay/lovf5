package AccelManager;

use strict;
use Common;

sub new {
	my ($class, $app, $view) = @_;
	my $this = {};
	$this->{'app'} = $app;
	$this->{'view'} = $view;
	bless $this, $class;
	return $this;
}

sub install {
	my $this = shift;
	my $view = $this->{'view'};
	my $app = $this->{'app'};

	# create accel group on main window
	my $main_window_accel_group = Gtk2::AccelGroup->new;

	# register global accelerator for main window
	$main_window_accel_group->connect(ord('x'), ['mod1-mask'], ['visible'], sub {
			change_window_status($app);
		});
	$main_window_accel_group->connect(ord('r'), ['control-mask'], ['visible'], sub {
			$view->expand_all_status;
		});
	$main_window_accel_group->connect(ord('m'), ['control-mask'], ['visible'], sub {
			$view->collapse_all_status;
		});
	$main_window_accel_group->connect(ord('a'), ['control-mask'], ['visible'], sub {
			$view->toggle_status_fold;
		});

	# register CTRL+U accelerator for send button's clicked event
	my $send_button = $app->get_widget('button_new_status_send');
	$send_button->add_accelerator('clicked', $main_window_accel_group, ord('j'), 'control-mask', 'visible');

	# add accelerator group to the main window
	my $window = $app->get_widget('main_window');
	$window->add_accel_group($main_window_accel_group);

	# create accel group on reply dialog
	my $reply_dialog_accel_group = Gtk2::AccelGroup->new;

	# register CTRL+U accelerator for reply button's clicked event
	my $reply_button = $app->get_widget('button_reply_ok');
	$reply_button->add_accelerator('clicked', $reply_dialog_accel_group, ord('j'), 'control-mask', 'visible');

	# add accelerator group to the reply dialog
	my $dlg_reply = $app->get_widget('dialog_reply');
	$dlg_reply->add_accel_group($reply_dialog_accel_group);
}

1; # terminate this package with 1
