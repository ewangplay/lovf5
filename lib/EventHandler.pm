package EventHandler;

# require module
use strict;
use Glib qw(TRUE FALSE);
use Encode qw(decode);

use Global;
use Common;

# construct
sub new {
	my ($class, $app, $f5api, $account, $view) = @_;
	my $this = {};
	$this->{'app'} = $app;
	$this->{'account'} = $account;
	$this->{'f5api'} = $f5api;
	$this->{'view'} = $view;
	$this->{'friends_status_column_width'} = 0;
	$this->{'my_status_column_width'} = 0;
	$this->{'public_status_column_width'} = 0;
	bless $this, $class;
	return $this;
}

##########################################################################################
# click event handler for staus send button on main window
sub on_button_new_status_send_clicked {
	my $this = shift;
	my $app = $this->{'app'};
	my $f5api= $this->{'f5api'};
	my $account = $this->{'account'};
	my $view = $this->{'view'};

	# get status text
	my $text_view = $app->get_widget('textview_new_status_text');
	my $text_buffer = $text_view->get_buffer;
	my ($start, $end) = $text_buffer->get_bounds;
	my $message = $text_buffer->get_text($start, $end, FALSE);

	if ($message eq '') {
		return FALSE;
	}

	# get the link
	my $label_link = $app->get_widget('label_link');
	my $link = $label_link->get_label;

	# submit the status
	my $result;
	if ($link eq '') {
		$result = $f5api->submitStatus(
			name => $account->name,
			password => $account->password,
			status => $message);	
	}
	else {
		$result = $f5api->submitStatus(
			name => $account->name,
			password => $account->password,
			status => $message,
			'link' => $link);	
	}
	if (!defined($result)) {
		MessageBox($text_view, 'error',
			decode('utf8', '发送信息失败，请重新尝试！'));
		return FALSE;
	}

	# update the status view
	$view->update;
	$view->update_statistic_data;
	$view->update_statistic_view;
	$view->move_first_status;

	# clear the status text
	$text_buffer->set_text('');
}

sub on_linkbutton_set_link_clicked {
	my $this = shift;
	my $app = $this->{'app'};
	my $dlg_input_link = $app->get_widget('dialog_input_link');
	my $entry_link = $app->get_widget('entry_link');
	$entry_link->select_region(0, -1);
	my $res = $dlg_input_link->run;
	if ($res eq 'ok') {
		my $link = $entry_link->get_text;
		my $label_link = $app->get_widget('label_link');
		$label_link->set_label($link);
		my $linkbutton_remove_link = $app->get_widget('linkbutton_remove_link');
		$linkbutton_remove_link->set_sensitive(TRUE);
	}
	$dlg_input_link->hide;
}

sub on_linkbutton_remove_link_clicked {
	my $this = shift;
	my $app = $this->{'app'};
	my $label_link = $app->get_widget('label_link');
	$label_link->set_label('');
	my $linkbutton_remove_link = $app->get_widget('linkbutton_remove_link');
	$linkbutton_remove_link->set_sensitive(FALSE);
}

sub on_button_link_ok_clicked {
	my $this = shift;
	my $app = $this->{'app'};
	my $dlg_input_link = $app->get_widget('dialog_input_link');
	my $entry_link = $app->get_widget('entry_link');
	my $link = $entry_link->get_text;
	if ($link eq '') {
		MessageBox($dlg_input_link, 'warning',
			decode('utf8', '链接地址不能为空！'));
		return FALSE;
	}
	$dlg_input_link->response('ok');
}

#######################################################################################
#login dialog event handler

# delete-event for login dialog
sub on_dialog_login_delete_event {
	$login_success = FALSE;
	Gtk2->main_quit;
}

# click event handler for login button on login dialog
sub on_button_login_ok_clicked {
	my $this = shift;
	my $app = $this->{'app'};
	my $f5api = $this->{'f5api'};
	my $account = $this->{'account'};
	my $dlg_login = $app->get_widget('dialog_login');
	my $entry_user = $app->get_widget('entry_user');
	my $entry_password = $app->get_widget('entry_password');
	my $checkbutton_remember_name = $app->get_widget('checkbutton_remember_name');
	my $checkbutton_remember_password = $app->get_widget('checkbutton_remember_password');
	my $checkbutton_auto_login = $app->get_widget('checkbutton_auto_login');
	my $name = $entry_user->get_text();
	my $password = $entry_password->get_text();

	$login_success = FALSE; #global

	if ($name eq '') {
		MessageBox($dlg_login, 'warning', decode('utf8', '用户名不能为空！'));
	}
	elsif ($password eq '') {
		MessageBox($dlg_login, 'warning', decode('utf8', '密码不能为空！'));
	}
	elsif (!($f5api->userVerify($name, $password))) {
		MessageBox($dlg_login, 'error', decode('utf8', '用户验证失败！'));
	}
	else {

		my $user_info = $f5api->getUserInfo(name => $name, password => $password);
		if (!defined($user_info)) {
			MessageBox($dlg_login, 'error',
				decode('utf8', '登录失败，请检查网络连接！'));
			return;
		}
		# set account info
		$account->name($name);
		$account->password($password);
		for my $key (keys %$user_info) {
			if ($key eq 'id') {
				my $users_id = $user_info->{'id'};
				$account->id($users_id->[0]);
			}	
			elsif ($key eq 'location') {
				my $users_location = $user_info->{'location'};
				$account->location($users_location->[0]);
			}
			elsif ($key eq 'description') {
				my $users_description = $user_info->{'description'};
				$account->description($users_description->[0]);
			}
			elsif ($key eq 'profile_image_url') {
				my $users_profile_image_url = $user_info->{'profile_image_url'};
				$account->profile_image_url($users_profile_image_url->[0]);
			}
			elsif ($key eq 'url') {
				my $users_url = $user_info->{'url'};
				$account->url($users_url->[0]);
			}
			elsif ($key eq 'sex') {
				my $users_sex = $user_info->{'sex'};
				$account->sex($users_sex->[0]);
			}
			elsif ($key eq 'birthday') {
				my $users_birthday = $user_info->{'birthday'};
				$account->birthday($users_birthday->[0]);
			}
			elsif ($key eq 'mobile') {
				my $users_mobile = $user_info->{'mobile'};
				$account->mobile($users_mobile->[0]);
			}
			elsif ($key eq 'qq') {
				my $users_qq = $user_info->{'qq'};
				$account->qq($users_qq->[0]);
			}
			elsif ($key eq 'msn') {
				my $users_msn = $user_info->{'msn'};
				$account->msn($users_msn->[0]);
			}
			elsif ($key eq 'email') {
				my $users_email = $user_info->{'email'};
				$account->email($users_email->[0]);
			}
			elsif ($key eq 'created_at') {
				my $users_created_at = $user_info->{'created_at'};
				$account->created_at($users_created_at->[0]);
			}
			elsif ($key eq 'favourites_count') {
				my $users_favourites_count = $user_info->{'favourites_count'};
				$account->favourites_count($users_favourites_count->[0]);
			}
			elsif ($key eq 'followers_count') {
				my $users_followers_count = $user_info->{'followers_count'};
				$account->followers_count($users_followers_count->[0]);
			}
			elsif ($key eq 'following_count') {
				my $users_following_count = $user_info->{'following_count'};
				$account->following_count($users_following_count->[0]);
			}
			elsif ($key eq 'friends_count') {
				my $users_friends_count = $user_info->{'friends_count'};
				$account->friends_count($users_friends_count->[0]);
			}
			elsif ($key eq 'statuses_count') {
				my $users_statuses_count = $user_info->{'statuses_count'};
				$account->statuses_count($users_statuses_count->[0]);
			}
		}

		# create user profile path
		my $user_profile_path = get_profile_dir() . "/" . $account->id;
		if (not -d $user_profile_path) {
			mkdir($user_profile_path, 0600);
		}

		# download the user profile image
		my $profile_image_url = $account->profile_image_url;
		system("wget -q -P $user_profile_path $profile_image_url");

		# set login state
		if ($checkbutton_auto_login->get_active) {
			$remember_name = TRUE;
			$remember_password = TRUE;
			$auto_login = TRUE;
		}
		elsif ($checkbutton_remember_password->get_active) {
			$remember_name = TRUE;
			$remember_password = TRUE;
			$auto_login = FALSE;
		}
		elsif ($checkbutton_remember_name->get_active) {
			$remember_name = TRUE;
			$remember_password = FALSE;
			$auto_login = FALSE;
		}
		else {
			$remember_name = FALSE;
			$remember_password = FALSE;
			$auto_login = FALSE;
		}

		# set login success flag
		$login_success = TRUE;

		# login success
		Gtk2->main_quit;
	}
}

# click event handler for cacel button on login dialog
sub on_button_login_cancel_clicked {
	$login_success = FALSE;
	Gtk2->main_quit;
}

# toggle event handler for remember-password checkbutton on login dialog
sub on_checkbutton_remember_password_toggled {
	my $this = shift;
	my $app = $this->{'app'};
	my $checkbutton_remember_name = $app->get_widget('checkbutton_remember_name');
	my $checkbutton_remember_password = $app->get_widget('checkbutton_remember_password');

	if ($checkbutton_remember_password->get_active) {
		$checkbutton_remember_name->set_active(TRUE);
		$checkbutton_remember_name->set_sensitive(FALSE);
	}
	else {
		$checkbutton_remember_name->set_sensitive(TRUE);
	}
}

# toggle event handler for auto-login checkbutton on login dialog
sub on_checkbutton_auto_login_toggled {
	my $this = shift;
	my $app = $this->{'app'};
	my $checkbutton_remember_name = $app->get_widget('checkbutton_remember_name');
	my $checkbutton_remember_password = $app->get_widget('checkbutton_remember_password');
	my $checkbutton_auto_login = $app->get_widget('checkbutton_auto_login');

	if ($checkbutton_auto_login->get_active) {
		$checkbutton_remember_name->set_active(TRUE);
		$checkbutton_remember_name->set_sensitive(FALSE);
		$checkbutton_remember_password->set_active(TRUE);
		$checkbutton_remember_password->set_sensitive(FALSE);
	}
	else {
		$checkbutton_remember_password->set_sensitive(TRUE);
	}
}


########################################################################################
#main window event handler

# check resize event handler for main window
sub on_main_window_check_resize {
	my $this = shift;
	my $app = $this->{'app'};
	my $tree_view;
	my $text_column;
	my @cell_renderers;
	my $text_renderer;
	my $column_width;
	
	# resize the freinds status window
	$tree_view = $app->get_widget('treeview_friends_status');
	$text_column = $tree_view->get_column(1);
	@cell_renderers = $text_column->get_cell_renderers;
	$text_renderer = $cell_renderers[0];
	if ($text_column->get_width > 0) {
		$column_width = $text_column->get_width;
		$this->{'friends_status_column_width'} = $column_width;
	}
	else {
		$column_width = $this->{'friends_status_column_width'};
	}
	$text_renderer->set('wrap-width' => $column_width - 10);
	$tree_view->queue_draw;

	# resize my status window
	$tree_view = $app->get_widget('treeview_my_status');
	$text_column = $tree_view->get_column(1);
	@cell_renderers = $text_column->get_cell_renderers;
	$text_renderer = $cell_renderers[0];
	if ($text_column->get_width > 0) {
		$column_width = $text_column->get_width;
		$this->{'my_status_column_width'} = $column_width;
	}
	else {
		$column_width = $this->{'my_status_column_width'};
	}
	$text_renderer->set('wrap-width' => $column_width - 10);
	$tree_view->queue_draw;

	# resize the public status window
	$tree_view = $app->get_widget('treeview_public_status');
	$text_column = $tree_view->get_column(1);
	@cell_renderers = $text_column->get_cell_renderers;
	$text_renderer = $cell_renderers[0];
	if ($text_column->get_width > 0) {
		$column_width = $text_column->get_width;
		$this->{'public_status_column_width'} = $column_width;
	}
	else {
		$column_width = $this->{'public_status_column_width'};
	}
	$text_renderer->set('wrap-width' => $column_width - 10);
	$tree_view->queue_draw;
}

# click event handler for status fresh button
sub on_linkbutton_refresh_clicked {
	my $this = shift;
	my $app = $this->{'app'};
	my $view = $this->{'view'};

	$view->update;
	$view->move_first_status;
}

# toggled event handler for auto-refresh checkbutton
sub on_checkbutton_auto_refresh_toggled {
	my $this = shift;
	my $app = $this->{'app'};
	my $view = $this->{'view'};

	my $checkbutton_auto_refresh = $app->get_widget('checkbutton_auto_refresh');
	if ($checkbutton_auto_refresh->get_active) {
		$view->auto_update;
	}
	else {
		$view->cancel_auto_update;
	}
}


###########################################################################################
#main menu event handler

# activate event handler for quit menu item
sub on_imagemenuitem_quit_activate {
	my $this = shift;
	my $app = $this->{'app'};

	quit_application($app);
}

# activate event handler for logout menu item
sub on_imagemenuitem_logout_activate {
	my $this = shift;
	my $app = $this->{'app'};

	# quit current process
	quit_application($app);

	# restart the program
	exec get_prefix_dir() . "/lovf5";
}

# activate event handler for option menu item
sub on_imagemenuitem_option_activate {
	my $this = shift;
	my $app = $this->{'app'};

	# get options dialog 
	my $dialog_options = $app->get_widget('dialog_options');
	$dialog_options->signal_connect('delete-event' => 
		sub {
			$_[0]->hide;
			return TRUE;
		});
	$dialog_options->signal_connect('response' => sub { $_[0]->hide });

	# show the options dialog
	$dialog_options->show_all;
}

# activate event handler for about menu item
sub on_imagemenuitem_about_activate {
	my $this = shift;
	my $app = $this->{'app'};

	# get the about dialog and show
	my $dialog_about = $app->get_widget('dialog_about');
	$dialog_about->signal_connect('delete-event' => 
		sub { 
			$_[0]->hide; 
			return TRUE;
	       	});
	$dialog_about->signal_connect('response' => sub { $_[0]->hide });
	$dialog_about->show_all;
}


######################################################################################
#status notebook event handler

sub on_notebook_statuses_switch_page {
	my $this = shift;
	$current_view_index = $_[2];	# signal params: 0: notebook; 1:page; 2:page index.
}

sub on_treeview_friends_status_button_press_event {
	my $this = shift;
	my $account = $this->{'account'};
	my ($treeview, $eventbutton) = @_;

	if ($eventbutton->button == 3) {
		# create the right button menu
		my $menu = Gtk2::Menu->new;

		# create the reply menu item
		my $reply_item = Gtk2::ImageMenuItem->new(decode('utf8', '回复'));
		my $reply_image = Gtk2::Image->new_from_stock('gtk-ok', 'menu');
		$reply_item->set_image($reply_image);
		$reply_item->signal_connect('activate', \&reply_status, $this);

		# append the reply menu item
		$menu->append($reply_item);

		# get the current user name
		my $current_username = $account->name;

		# get the status's user name
		my $tree_selection = $treeview->get_selection;
		my ($tree_model, $tree_iter) = $tree_selection->get_selected;
		my $status_username = $tree_model->get($tree_iter, 1);

		# create the delete menu item
		my $delete_item = Gtk2::ImageMenuItem->new_from_stock('gtk-delete');
		$delete_item->signal_connect('activate', \&delete_status, $this);
		$delete_item->set_sensitive($current_username eq $status_username);

		# append the delete menu item to the menu
		$menu->append($delete_item);

		# popup the right button menu
		$menu->show_all;
		$menu->popup(
			undef,
			undef,
			undef,
			undef,
			$eventbutton->button,
			$eventbutton->time
		);
	}
}

sub on_treeview_my_status_button_press_event {
	my $this = shift;
	my $account = $this->{'account'};
	my ($treeview, $eventbutton) = @_;

	if ($eventbutton->button == 3) {
		# create the right button menu
		my $menu = Gtk2::Menu->new;

		# create the reply menu item
		my $reply_item = Gtk2::ImageMenuItem->new(decode('utf8', '回复'));
		my $reply_image = Gtk2::Image->new_from_stock('gtk-ok', 'menu');
		$reply_item->set_image($reply_image);
		$reply_item->signal_connect('activate', \&reply_status, $this);

		# append the reply menu item
		$menu->append($reply_item);

		# get the current user name
		my $current_username = $account->name;

		# get the status's user name
		my $tree_selection = $treeview->get_selection;
		my ($tree_model, $tree_iter) = $tree_selection->get_selected;
		my $status_username = $tree_model->get($tree_iter, 1);

		# create the delete menu item
		my $delete_item = Gtk2::ImageMenuItem->new_from_stock('gtk-delete');
		$delete_item->signal_connect('activate', \&delete_status, $this);
		$delete_item->set_sensitive($current_username eq $status_username);

		# append the delete menu item to the menu
		$menu->append($delete_item);

		# popup the right button menu
		$menu->show_all;
		$menu->popup(
			undef,
			undef,
			undef,
			undef,
			$eventbutton->button,
			$eventbutton->time
		);
	}
}

sub on_treeview_public_status_button_press_event {
	my $this = shift;
	my $account = $this->{'account'};
	my ($treeview, $eventbutton) = @_;

	if ($eventbutton->button == 3) {
		# create the right button menu
		my $menu = Gtk2::Menu->new;

		# create the reply menu item
		my $reply_item = Gtk2::ImageMenuItem->new(decode('utf8', '回复'));
		my $reply_image = Gtk2::Image->new_from_stock('gtk-ok', 'menu');
		$reply_item->set_image($reply_image);
		$reply_item->signal_connect('activate', \&reply_status, $this);

		# append the reply menu item
		$menu->append($reply_item);

		# get the current user name
		my $current_username = $account->name;

		# get the status's user name
		my $tree_selection = $treeview->get_selection;
		my ($tree_model, $tree_iter) = $tree_selection->get_selected;
		my $status_username = $tree_model->get($tree_iter, 1);

		# create the delete menu item
		my $delete_item = Gtk2::ImageMenuItem->new_from_stock('gtk-delete');
		$delete_item->signal_connect('activate', \&delete_status, $this);
		$delete_item->set_sensitive($current_username eq $status_username);

		# append the delete menu item to the menu
		$menu->append($delete_item);

		# popup the right button menu
		$menu->show_all;
		$menu->popup(
			undef,
			undef,
			undef,
			undef,
			$eventbutton->button,
			$eventbutton->time
		);
	}
}

sub reply_status {
	my $this = $_[-1]; # get the last user-defined data
	my $app = $this->{'app'};
	my $f5api = $this->{'f5api'};
	my $account = $this->{'account'};
	my $view = $this->{'view'};
	my $treeview;
	my $select_child = FALSE;

	if ($current_view_index == $FRIENDS_STATUS_VIEW_INDEX) {
		$treeview = $app->get_widget('treeview_friends_status');
	}
	elsif ($current_view_index == $MY_STATUS_VIEW_INDEX) {
		$treeview = $app->get_widget('treeview_my_status');
	}
	elsif ($current_view_index == $PUBLIC_STATUS_VIEW_INDEX) {
		$treeview = $app->get_widget('treeview_public_status');
	}

	# get the selected status id
	my $status_id;
	my $tree_selection = $treeview->get_selection;
	my ($tree_model, $tree_iter) = $tree_selection->get_selected;
	my $parent_iter = $tree_model->iter_parent($tree_iter);
	if (defined($parent_iter)) {
		$status_id = $tree_model->get($parent_iter, 0);
		$select_child = TRUE;
	}
	else {
		$status_id = $tree_model->get($tree_iter, 0);
	}
	# get the selelcted status user name
	my $status_username = $tree_model->get($tree_iter, 1);

	my $reply_text;
	my $dlg_reply = $app->get_widget('dialog_reply');
	my $text_view = $app->get_widget('textview_reply');
	my $text_buffer = $text_view->get_buffer;
	if ($select_child) {
		$text_buffer->set_text(decode('utf8', '回复[') . $status_username . '] ');
	}
	else {
		$text_buffer->set_text('');
	}
	my $res = $dlg_reply->run;
	if ($res eq 'ok') {
		# get the reply text
		my ($start, $end) = $text_buffer->get_bounds;
		$reply_text = $text_buffer->get_text($start, $end, FALSE);

		# submit the status reply
		my $result = $f5api->submitStatusReply(
			name => $account->name,
			password => $account->password,
			id => $status_id,
			status => $reply_text
		);
		if (!defined($result)) {
			MessageBox(undef,
				'warning',
				decode('utf8', '回复失败,请重新尝试！'));
			return FALSE;
		}

		# update the status
		$view->update;
	}
	$dlg_reply->hide;
}

sub delete_status {
	my $this = $_[-1];
	my $app = $this->{'app'};
	my $view = $this->{'view'};
	my $f5api = $this->{'f5api'};
	my $account = $this->{'account'};
	my $treeview;

	if ($current_view_index == $FRIENDS_STATUS_VIEW_INDEX) {
		$treeview = $app->get_widget('treeview_friends_status');
	}
	elsif ($current_view_index == $MY_STATUS_VIEW_INDEX) {
		$treeview = $app->get_widget('treeview_my_status');
	}
	elsif ($current_view_index == $PUBLIC_STATUS_VIEW_INDEX) {
		$treeview = $app->get_widget('treeview_public_status');
	}

	# get the selected status id
	my $tree_selection = $treeview->get_selection;
	my ($tree_model, $tree_iter) = $tree_selection->get_selected;
	my $status_id = $tree_model->get($tree_iter, 0);

	# delete the selected status from follow5 server
	my $delete_success = $f5api->deleteStatus(
		name => $account->name,
		password => $account->password,
		id => $status_id
	);
	if (!$delete_success) {
		MessageBox(undef,
			'warning',
			decode('utf8', '删除失败，请重新尝试！'));
		return FALSE;
	}

	# delete the selected status from tree view
	$tree_model->remove($tree_iter);

	# update the status view
	$view->update;
	$view->update_statistic_data;
	$view->update_statistic_view;
}

sub on_button_reply_ok_clicked {
	my $this = shift;
	my $app = $this->{'app'};
	my $dlg_reply = $app->get_widget('dialog_reply');
	my $text_view = $app->get_widget('textview_reply');
	my $text_buffer = $text_view->get_buffer;
	my ($start, $end) = $text_buffer->get_bounds;
	my $reply_text = $text_buffer->get_text($start, $end, FALSE);
	if ($reply_text eq '') {
		MessageBox(undef,
			'warning',
			decode('utf8', '回复文本不能为空！'));
		return FALSE;
	}
	$dlg_reply->response('ok');
}

########################################################################################
#options dialog event handler

sub on_combobox_update_freq_changed {
	my $this = shift;
	my $app = $this->{'app'};
	my $combobox = $app->get_widget('combobox_update_freq');
	my $index = $combobox->get_active;
	$update_frequency = $index ? ($index * 5 * 60) : (($index + 1) * 60);
}

sub on_colorbutton_status_foreground_color_set {
	my $this = shift;
	my $colorbutton = shift;
	my $foreground_color = $colorbutton->get_color;
	$foreground_red = $foreground_color->red; #global
	$foreground_green = $foreground_color->green; #global
	$foreground_blue = $foreground_color->blue; #global

	# update foreground color
	my $view = $this->{'view'};
	$view->set_foreground_color($foreground_color);
}

sub on_colorbutton_status_background_color_set {
	my $this = shift;
	my $colorbutton = shift;
	my $background_color = $colorbutton->get_color;
	$background_red = $background_color->red; #global
	$background_green = $background_color->green; #global
	$background_blue = $background_color->blue; #global

	# update background color
	my $view = $this->{'view'};
	$view->set_background_color($background_color);
}

sub on_button_restore_foreground_default_clicked {
	my $this = shift;
	my $app = $this->{'app'};

	$foreground_red = $FOREGROUND_RED_DEFAULT;
	$foreground_green = $FOREGROUND_GREEN_DEFAULT;
	$foreground_blue = $FOREGROUND_BLUE_DEFAULT;

	# set foreground color button
	my $colorbutton = $app->get_widget('colorbutton_status_foreground');
	my $color = Gtk2::Gdk::Color->new($foreground_red, $foreground_green, $foreground_blue);
	$colorbutton->set_color($color);

	# set foreground color of status window
	my $view = $this->{'view'};
	$view->set_foreground_color($color);
}

sub on_button_restore_background_default_clicked {
	my $this = shift;
	my $app = $this->{'app'};

	$background_red = $BACKGROUND_RED_DEFAULT;
	$background_green = $BACKGROUND_GREEN_DEFAULT;
	$background_blue = $BACKGROUND_BLUE_DEFAULT;

	# set background color button
	my $colorbutton = $app->get_widget('colorbutton_status_background');
	my $color = Gtk2::Gdk::Color->new($background_red, $background_green, $background_blue);
	$colorbutton->set_color($color);

	# set foreground color of status window
	my $view = $this->{'view'};
	$view->set_background_color($color);
}

sub on_fontbutton_status_font_font_set {
	my $this = shift;
	my $fontbutton = shift;

	$status_fontname = $fontbutton->get_font_name; #global

	# set status font
	my $view = $this->{'view'};
	$view->set_status_font($status_fontname);
}

sub on_button_restore_status_font_default_clicked {
	my $this = shift;
	my $app = $this->{'app'};

	$status_fontname = $FONTNAME_DEFAULT;	#global

	my $fontbutton = $app->get_widget('fontbutton_status_font');
	$fontbutton->set_font_name($status_fontname);

	my $view = $this->{'view'};
	$view->set_status_font($status_fontname);
}

1; #terminate this package with 1
