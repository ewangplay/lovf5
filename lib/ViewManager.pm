package ViewManager;

# require module 
use strict;
use Glib qw(TRUE FALSE);
use HTTP::Date;
use Common;

#construct
sub new {
	my ($class, $app, $f5api, $account) = @_;
	my $this = {};
	$this->{'app'} = $app;
	$this->{'account'} = $account;
	$this->{'f5api'} = $f5api;
	$this->{'friends_status_tree_store'} = Gtk2::TreeStore->new(qw/Glib::String Glib::String Glib::String Glib::String Glib::String Glib::String Glib::String/);
	$this->{'my_status_tree_store'} = Gtk2::TreeStore->new(qw/Glib::String Glib::String Glib::String Glib::String Glib::String Glib::String Glib::String/);
	$this->{'public_status_tree_store'} = Gtk2::TreeStore->new(qw/Glib::String Glib::String Glib::String Glib::String Glib::String Glib::String Glib::String/);
	$this->{'update_event_id'} = 0;
	$this->{'friends_status'} = {};
	$this->{'friends_status'}->{'last_time'} = 0;
	$this->{'friends_status'}->{'statuses'} = {};
	$this->{'my_status'} = {};
	$this->{'my_status'}->{'last_time'} = 0;
	$this->{'my_status'}->{'statuses'} = {};
	$this->{'public_status'} = {};
	$this->{'public_status'}->{'last_time'} = 0;
	$this->{'public_status'}->{'statuses'} = {};
	bless $this, $class;
	return $this;
}

# initialize view
sub init {
	my $this = shift;

	if (!$this->init_statistic_view()) {
		return FALSE;
	}

	if (!$this->update_data()) {
		return FALSE;
	}

	if (!$this->update_view()) {
		return FALSE;
	}

	return TRUE;
}

sub update {
	my $this = shift;
	my $app = $this->{'app'};

	if ($current_view_index == $FRIENDS_STATUS_VIEW_INDEX) {
		if (!$this->update_friends_status_data()) {
			return FALSE;
		}
	}
	elsif ($current_view_index == $MY_STATUS_VIEW_INDEX) {
		if (!$this->update_my_status_data()) {
			return FALSE;
		}
	}
	elsif ($current_view_index == $PUBLIC_STATUS_VIEW_INDEX) {
		if (!$this->update_public_status_data()) {
			return FALSE;
		}
	}

	return TRUE;
}

sub auto_update {
	my $this = shift;
	my $update_event_id = Glib::Timeout->add_seconds($update_frequency, \&update, $this);
	if ($update_event_id <=  0) {
		return FALSE;
	}

	$this->{'update_event_id'} = $update_event_id;

	return TRUE;
}

sub cancel_auto_update {
	my $this = shift;
	if(!Glib::Source->remove($this->{'update_event_id'})) {
		return FALSE;
	}
	return TRUE;
}

sub update_data {
	my $this = shift;

	if (!$this->update_statistic_data()) {
		return FALSE;
	}

	if (!$this->update_friends_status_data()) {
		return FALSE;
	}

	if (!$this->update_my_status_data()) {
		return FALSE;
	}

	if (!$this->update_public_status_data()) {
		return FALSE;
	}

	return TRUE;
}

sub update_view {
	my $this = shift;

	if (!$this->update_statistic_view()) {
		return FALSE;
	}

	if (!$this->update_friends_status_view()) {
		return FALSE;
	}

	if (!$this->update_my_status_view()) {
		return FALSE;
	}

	if (!$this->update_public_status_view()) {
		return FALSE;
	}

	return TRUE;

}

# initialize the statistic view
sub init_statistic_view {
	my $this = shift;
	my $app = $this->{'app'};
	my $account = $this->{'account'};

	# update head image
	my $head_image_file =  get_profile_dir() . "/" . $this->{'account'}->id . "/" . $account->id . ".jpg";
	my $image_head = $app->get_widget('image_head');
	$image_head->set_from_file($head_image_file);

	# update user name
	my $label_username = $app->get_widget('label_username');
	$label_username->set_text($account->name);

	return TRUE;
}


sub update_statistic_data {
	my $this = shift;
	my $account = $this->{'account'};
	my $f5api = $this->{'f5api'};

	my $user_info = $f5api->getUserInfo(name => $account->name,
	       				password => $account->password);
	if (!defined($user_info)) {
		return FALSE;
	}

	for my $key (keys %$user_info) {
		if ($key eq 'favourites_count') {
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

	return TRUE;
}

# update the statistic view
sub update_statistic_view {
	my $this = shift;
	my $app = $this->{'app'};
	my $account = $this->{'account'};

	# update my statuses num
	my $label_statuses_num = $app->get_widget('label_statuses_num');
	$label_statuses_num->set_text($account->statuses_count);

	# update my follow's user num
	my $label_follow_num = $app->get_widget('label_follow_num');
	$label_follow_num->set_text($account->following_count);

	# update the user num who follows me
	my $label_followed_num = $app->get_widget('label_followed_num');
	$label_followed_num->set_text($account->followers_count);

	# update the firends num
	my $label_friends_num = $app->get_widget('label_friends_num');
	$label_friends_num->set_text($account->friends_count);

	# update the my favorit num
	my $label_favorit_num = $app->get_widget('label_favorit_num');
	$label_favorit_num->set_text($account->favourites_count);

	return TRUE;
}

sub update_friends_status_data {
	my $this = shift;
	my $account = $this->{'account'};
	my $f5api = $this->{'f5api'};

	# get the latest friends status from follow5 server
	my $ref_friends_status = $f5api->getFriendsStatus(name => $account->name, 
		password => $account->password,
		count => 20);
	if (!defined($ref_friends_status)) {
		return FALSE;
	}

	# get the friends status list store 
	my $tree_store = $this->{'friends_status_tree_store'};

	# store the friends statuses into the tree store 
	my $last_time = $this->{'friends_status'}->{'last_time'};
	for my $key_one (keys %$ref_friends_status) {
		if (not $key_one eq 'status') {
			return FALSE;
		}
		my $ref_arr_statuses = $ref_friends_status->{$key_one};
		for my $ref_status (reverse @$ref_arr_statuses) {
			# parse the status info
			my ($id, $receiver, $source, $created_at, $text, $reply_count);
			my ($user_id, $user_name, $user_profile_image_url, $user_url);
			for my $key_two (keys %$ref_status) {
				if ($key_two eq 'receiver') {
					$receiver = $ref_status->{$key_two}->[0];
				}
				elsif ($key_two eq 'source') {
					$source = $ref_status->{$key_two}->[0];
				}
				elsif ($key_two eq 'created_at') {
					$created_at = $ref_status->{$key_two}->[0];
				}
				elsif ($key_two eq 'text') {
					$text = $ref_status->{$key_two}->[0];
					$text =~ s/<br\/>/ /g;
				}
				elsif ($key_two eq 'id') {
					$id = $ref_status->{$key_two}->[0];
				}
				elsif ($key_two eq 'reply_count') {
					$reply_count = $ref_status->{$key_two}->[0];
				}
				elsif ($key_two eq 'user') {
					my $ref_user = $ref_status->{$key_two}->[0];
					for my $key_three (keys %$ref_user) {
						if ($key_three eq 'name') {
							$user_name = $ref_user->{$key_three}->[0];
						}
						elsif ($key_three eq 'profile_image_url') {
							$user_profile_image_url = $ref_user->{$key_three}->[0];
						}
						elsif ($key_three eq 'id') {
							$user_id = $ref_user->{$key_three}->[0];
						}
						elsif ($key_three eq 'url') {
							$user_url = $ref_user->{$key_three}->[0];
						}
					}
				}
			}


			my $current_time = str2time($created_at);
			my $iter;
			if ($current_time > $last_time) { #handle new status
				# save the latest time
				$last_time = $current_time;

				# insert a row into the liststore
				$iter = $tree_store->insert(undef, 0);

				# save the status tree iter
				$this->{'friends_status'}->{'statuses'}->{$id}->{'tree_iter'} = $iter;
				$this->{'friends_status'}->{'statuses'}->{$id}->{'reply_last_time'} = 0;

				# set column data for the added row
				$tree_store->set(
					$iter,
					0 => $id,
					1 => $user_name,
					2 => $user_profile_image_url,
					3 => $source,
					4 => $receiver,
					5 => $created_at,
					6 => $text);
			}
			else {
				$iter = $this->{'friends_status'}->{'statuses'}->{$id}->{'tree_iter'}; 
			}

			# get the reply list for this status and insert into the tree store
			if ($reply_count > 0) {
				my $ref_status_replies = $f5api->getStatusReply(id => $id);
				if (!defined($ref_status_replies)) {
					return FALSE;
				}

				my $reply_last_time = $this->{'friends_status'}->{'statuses'}->{$id}->{'reply_last_time'};
				my $ref_arr_replies = $ref_status_replies->{'relpyes'}->[0]->{'reply'};
				for my $ref_reply (@$ref_arr_replies) {
					my ($reply_source, $reply_created_at, $reply_text, $reply_id);
					my ($reply_user_id, $reply_user_name, $reply_user_profile_image_url, $reply_user_url);
					my $reply_receiver = $user_name;
					for my $reply_key (keys %$ref_reply) {
						if ($reply_key eq 'source') {
							$reply_source = $ref_reply->{$reply_key}->[0];
						}
						elsif ($reply_key eq 'created_at') {
							$reply_created_at = $ref_reply->{$reply_key}->[0];
						}
						elsif ($reply_key eq 'text') {
							$reply_text = $ref_reply->{$reply_key}->[0];
						}
						elsif ($reply_key eq 'id') {
							$reply_id = $ref_reply->{$reply_key}->[0];
						}
						elsif ($reply_key eq 'user') {
							my $ref_reply_user = $ref_reply->{$reply_key}->[0];
							for my $reply_user_key (%$ref_reply_user) {
								if ($reply_user_key eq 'url') {
									$reply_user_url = $ref_reply_user->{$reply_user_key}->[0];
								}
								elsif ($reply_user_key eq 'profile_image_url') {
									$reply_user_profile_image_url = $ref_reply_user->{$reply_user_key}->[0];
								}
								elsif ($reply_user_key eq 'name') {
									$reply_user_name = $ref_reply_user->{$reply_user_key}->[0];
								}
								elsif ($reply_user_key eq 'id') {
									$reply_user_id = $ref_reply_user->{$reply_user_key}->[0];
								}
							}
						}
					}

					my $current_reply_time = str2time($reply_created_at);
					if ($current_reply_time > $reply_last_time) {
						# save the last reply time
						$reply_last_time = $current_reply_time;

						#insert the reply into the tree store
						my $reply_iter = $tree_store->insert($iter, 0);

						$tree_store->set(
							$reply_iter,
							0 => $reply_id,
							1 => $reply_user_name,
							2 => $reply_user_profile_image_url,
							3 => $reply_source,
							4 => $reply_receiver,
							5 => $reply_created_at,
							6 => $reply_text);
					}
				}
				$this->{'friends_status'}->{'statuses'}->{$id}->{'reply_last_time'} = $reply_last_time;
			}
		}
	}

	# save the last status created time
	$this->{'friends_status'}->{'last_time'} = $last_time;

	return TRUE;
}

sub update_friends_status_view {
	my $this = shift;
	my $app = $this->{'app'};

	# get the friends status treeview widget
	my $tree_view = $app->get_widget('treeview_friends_status');

	# get the friends status list store
	my $tree_store = $this->{'friends_status_tree_store'};

	# attach the liststore to the treeview
	$tree_view->set_model($tree_store);

	# create the user column
	my $user_column = Gtk2::TreeViewColumn->new();

	# create the user name renderer
	my $user_renderer = Gtk2::CellRendererText->new();
	$user_renderer->set('wrap-mode' => 'word');
	$user_renderer->set('alignment' => 'center');

	# pack the user renderer into the text tree column
	$user_column->pack_start($user_renderer, FALSE);

	# set the user renderer 'text' attribute to column 1 of list store
	$user_column->add_attribute($user_renderer, text => 1);

	# append the user column into the tree view
	$tree_view->append_column($user_column);

	# create the text column
	my $text_column = Gtk2::TreeViewColumn->new();
	$text_column->set('sizing' => 'GTK_TREE_VIEW_COLUMN_FIXED');

	# create the text renderer
	my $text_renderer = Gtk2::CellRendererText->new();
	$text_renderer->set('wrap-mode' => 'word');
	$text_renderer->set('wrap-width' => 300);

	# pack the text renderer into the text tree column
	$text_column->pack_start($text_renderer, FALSE);

	# set the cell renderer 'text' attribute to column 6 of liststore
	$text_column->add_attribute($text_renderer, text => 6);

	# append the text column to the tree view
	$tree_view->append_column($text_column);

	return TRUE;
}

sub update_my_status_data {
	my $this = shift;
	my $account = $this->{'account'};
	my $f5api = $this->{'f5api'};

	# get the my status from follow5 server
	my $ref_my_status = $f5api->getUserStatus(name => $account->name, 
		password => $account->password,
		count => 20);
	if (!defined($ref_my_status)) {
		return FALSE;
	}

	# get my status list store
	my $tree_store = $this->{'my_status_tree_store'};

	# store my statuses into the list store 
	my $last_time = $this->{'my_status'}->{'last_time'};
	for my $key_one (keys %$ref_my_status) {
		if (not $key_one eq 'status') {
			return FALSE;
		}
		my $ref_arr_statuses = $ref_my_status->{$key_one};
		for my $ref_status (reverse @$ref_arr_statuses) {
			# parse the status info
			my ($id, $receiver, $source, $created_at, $text, $reply_count);
			my ($user_name, $user_profile_image_url);
			for my $key_two (keys %$ref_status) {
				if ($key_two eq 'receiver') {
					$receiver = $ref_status->{$key_two}->[0];
				}
				elsif ($key_two eq 'source') {
					$source = $ref_status->{$key_two}->[0];
				}
				elsif ($key_two eq 'created_at') {
					$created_at = $ref_status->{$key_two}->[0];
				}
				elsif ($key_two eq 'text') {
					$text = $ref_status->{$key_two}->[0];
					$text =~ s/<br\/>//g;
				}
				elsif ($key_two eq 'id') {
					$id = $ref_status->{$key_two}->[0];
				}
				elsif ($key_two eq 'reply_count') {
					$reply_count = $ref_status->{$key_two}->[0];
				}
				elsif ($key_two eq 'user') {
					my $ref_user = $ref_status->{$key_two}->[0];
					for my $key_three (keys %$ref_user) {
						if ($key_three eq 'name') {
							$user_name = $ref_user->{$key_three}->[0];
						}
						elsif ($key_three eq 'profile_image_url') {
							$user_profile_image_url = $ref_user->{$key_three}->[0];
						}
					}
				}
			}

			my $current_time = str2time($created_at);
			my $iter;
			if ($current_time > $last_time) {
				# save the latest time
				$last_time = $current_time;

				# insert a row into the liststore
				$iter = $tree_store->insert(undef, 0);

				# save the status tree iter
				$this->{'my_status'}->{'statuses'}->{$id}->{'tree_iter'} = $iter;
				$this->{'my_status'}->{'statuses'}->{$id}->{'reply_last_time'} = 0;

				# set column data for the added row
				$tree_store->set(
					$iter,
					0 => $id,
					1 => $user_name,
					2 => $user_profile_image_url,
					3 => $source,
					4 => $receiver,
					5 => $created_at,
					6 => $text);
			}
			else {
				$iter = $this->{'my_status'}->{'statuses'}->{$id}->{'tree_iter'};
			}

			# get the reply list for this status and insert into the tree store
			if ($reply_count > 0) {
				my $ref_status_replies = $f5api->getStatusReply(id => $id);
				if (!defined($ref_status_replies)) {
					return FALSE;
				}

				my $reply_last_time = $this->{'my_status'}->{'statuses'}->{$id}->{'reply_last_time'};
				my $ref_arr_replies = $ref_status_replies->{'relpyes'}->[0]->{'reply'};
				for my $ref_reply (@$ref_arr_replies) {
					my ($reply_source, $reply_created_at, $reply_text, $reply_id);
					my ($reply_user_id, $reply_user_name, $reply_user_profile_image_url, $reply_user_url);
					my $reply_receiver = $user_name;
					for my $reply_key (keys %$ref_reply) {
						if ($reply_key eq 'source') {
							$reply_source = $ref_reply->{$reply_key}->[0];
						}
						elsif ($reply_key eq 'created_at') {
							$reply_created_at = $ref_reply->{$reply_key}->[0];
						}
						elsif ($reply_key eq 'text') {
							$reply_text = $ref_reply->{$reply_key}->[0];
						}
						elsif ($reply_key eq 'id') {
							$reply_id = $ref_reply->{$reply_key}->[0];
						}
						elsif ($reply_key eq 'user') {
							my $ref_reply_user = $ref_reply->{$reply_key}->[0];
							for my $reply_user_key (%$ref_reply_user) {
								if ($reply_user_key eq 'url') {
									$reply_user_url = $ref_reply_user->{$reply_user_key}->[0];
								}
								elsif ($reply_user_key eq 'profile_image_url') {
									$reply_user_profile_image_url = $ref_reply_user->{$reply_user_key}->[0];
								}
								elsif ($reply_user_key eq 'name') {
									$reply_user_name = $ref_reply_user->{$reply_user_key}->[0];
								}
								elsif ($reply_user_key eq 'id') {
									$reply_user_id = $ref_reply_user->{$reply_user_key}->[0];
								}
							}
						}
					}

					my $current_reply_time = str2time($reply_created_at);
					if ($current_reply_time > $reply_last_time) {
						# save the last reply time
						$reply_last_time = $current_reply_time;

						#insert the reply into the tree store
						my $reply_iter = $tree_store->insert($iter, 0);

						$tree_store->set(
							$reply_iter,
							0 => $reply_id,
							1 => $reply_user_name,
							2 => $reply_user_profile_image_url,
							3 => $reply_source,
							4 => $reply_receiver,
							5 => $reply_created_at,
							6 => $reply_text);
					}
				}
				$this->{'my_status'}->{'statuses'}->{$id}->{'reply_last_time'} = $reply_last_time;
			}
		}
	}

	# save the last status created time
	$this->{'my_status'}->{'last_time'} = $last_time;

	return TRUE;
}

sub update_my_status_view {
	my $this = shift;
	my $app = $this->{'app'};

	# get my status treeview widget
	my $tree_view = $app->get_widget('treeview_my_status');

	# get my status list store
	my $tree_store = $this->{'my_status_tree_store'};

	# attach the liststore to the treeview
	$tree_view->set_model($tree_store);

	# create the user column
	my $user_column = Gtk2::TreeViewColumn->new();

	# create the user name renderer
	my $user_renderer = Gtk2::CellRendererText->new();
	$user_renderer->set('wrap-mode' => 'word');
	$user_renderer->set('alignment' => 'center');

	# pack the user renderer into the text tree column
	$user_column->pack_start($user_renderer, FALSE);

	# set the user renderer 'text' attribute to column 1 of list store
	$user_column->add_attribute($user_renderer, text => 1);

	# append the user column into the tree view
	$tree_view->append_column($user_column);

	# create the text column
	my $text_column = Gtk2::TreeViewColumn->new();
	$text_column->set('sizing' => 'GTK_TREE_VIEW_COLUMN_FIXED');

	# create the text renderer
	my $text_renderer = Gtk2::CellRendererText->new();
	$text_renderer->set('wrap-mode' => 'word');
	$text_renderer->set('wrap-width' => 300);

	# pack the text renderer into the text tree column
	$text_column->pack_start($text_renderer, FALSE);

	# set the cell renderer 'text' attribute to column 6 of liststore
	$text_column->add_attribute($text_renderer, text => 6);

	# append the text column to the tree view
	$tree_view->append_column($text_column);

	return TRUE;
}

sub update_public_status_data {
	my $this = shift;
	my $account = $this->{'account'};
	my $f5api = $this->{'f5api'};

	# get the public status from follow5 server
	my $ref_public_status = $f5api->getPublicStatus();
	if (!defined($ref_public_status)) {
		return FALSE;
	}

	# get the public status list store
	my $tree_store = $this->{'public_status_tree_store'};

	# store the public statuses into the liststore 
	my $last_time = $this->{'public_status'}->{'last_time'};
	for my $key_one (keys %$ref_public_status) {
		if (not $key_one eq 'status') {
			return FALSE;
		}
		my $ref_arr_statuses = $ref_public_status->{$key_one};
		for my $ref_status (reverse @$ref_arr_statuses) {
			# parse the status info
			my ($id, $receiver, $source, $created_at, $text, $reply_count);
			my ($user_name, $user_profile_image_url);
			for my $key_two (keys %$ref_status) {
				if ($key_two eq 'receiver') {
					$receiver = $ref_status->{$key_two}->[0];
				}
				elsif ($key_two eq 'source') {
					$source = $ref_status->{$key_two}->[0];
				}
				elsif ($key_two eq 'created_at') {
					$created_at = $ref_status->{$key_two}->[0];
				}
				elsif ($key_two eq 'text') {
					$text = $ref_status->{$key_two}->[0];
					$text =~ s/<br\/>//g;
				}
				elsif ($key_two eq 'id') {
					$id = $ref_status->{$key_two}->[0];
				}
				elsif ($key_two eq 'reply_count') {
					$reply_count = $ref_status->{$key_two}->[0];
				}
				elsif ($key_two eq 'user') {
					my $ref_user = $ref_status->{$key_two}->[0];
					for my $key_three (keys %$ref_user) {
						if ($key_three eq 'name') {
							$user_name = $ref_user->{$key_three}->[0];
						}
						elsif ($key_three eq 'profile_image_url') {
							$user_profile_image_url = $ref_user->{$key_three}->[0];
						}
					}
				}
			}

			my $current_time = str2time($created_at);
			my $iter;
			if ($current_time > $last_time) {
				# save the latest time
				$last_time = $current_time;

				# insert a row into the liststore
				$iter = $tree_store->insert(undef, 0);

				# save the status tree iter
				$this->{'public_status'}->{'statuses'}->{$id}->{'tree_iter'} = $iter;
				$this->{'public_status'}->{'statuses'}->{$id}->{'reply_last_time'} = 0;

				# set column data for the added row
				$tree_store->set(
					$iter,
					0 => $id,
					1 => $user_name,
					2 => $user_profile_image_url,
					3 => $source,
					4 => $receiver,
					5 => $created_at,
					6 => $text);
			}
			else {
				$iter = $this->{'public_status'}->{'statuses'}->{$id}->{'tree_iter'}; 
			}

			# get the reply list for this status and insert into the tree store
			if ($reply_count > 0) {
				my $ref_status_replies = $f5api->getStatusReply(id => $id);
				if (!defined($ref_status_replies)) {
					return FALSE;
				}

				my $reply_last_time = $this->{'public_status'}->{'statuses'}->{$id}->{'reply_last_time'};
				my $ref_arr_replies = $ref_status_replies->{'relpyes'}->[0]->{'reply'};
				for my $ref_reply (@$ref_arr_replies) {
					my ($reply_source, $reply_created_at, $reply_text, $reply_id);
					my ($reply_user_id, $reply_user_name, $reply_user_profile_image_url, $reply_user_url);
					my $reply_receiver = $user_name;
					for my $reply_key (keys %$ref_reply) {
						if ($reply_key eq 'source') {
							$reply_source = $ref_reply->{$reply_key}->[0];
						}
						elsif ($reply_key eq 'created_at') {
							$reply_created_at = $ref_reply->{$reply_key}->[0];
						}
						elsif ($reply_key eq 'text') {
							$reply_text = $ref_reply->{$reply_key}->[0];
						}
						elsif ($reply_key eq 'id') {
							$reply_id = $ref_reply->{$reply_key}->[0];
						}
						elsif ($reply_key eq 'user') {
							my $ref_reply_user = $ref_reply->{$reply_key}->[0];
							for my $reply_user_key (%$ref_reply_user) {
								if ($reply_user_key eq 'url') {
									$reply_user_url = $ref_reply_user->{$reply_user_key}->[0];
								}
								elsif ($reply_user_key eq 'profile_image_url') {
									$reply_user_profile_image_url = $ref_reply_user->{$reply_user_key}->[0];
								}
								elsif ($reply_user_key eq 'name') {
									$reply_user_name = $ref_reply_user->{$reply_user_key}->[0];
								}
								elsif ($reply_user_key eq 'id') {
									$reply_user_id = $ref_reply_user->{$reply_user_key}->[0];
								}
							}
						}
					}

					my $current_reply_time = str2time($reply_created_at);
					if ($current_reply_time > $reply_last_time) {
						# save the last reply time
						$reply_last_time = $current_reply_time;

						#insert the reply into the tree store
						my $reply_iter = $tree_store->insert($iter, 0);

						$tree_store->set(
							$reply_iter,
							0 => $reply_id,
							1 => $reply_user_name,
							2 => $reply_user_profile_image_url,
							3 => $reply_source,
							4 => $reply_receiver,
							5 => $reply_created_at,
							6 => $reply_text);
					}
				}
				$this->{'public_status'}->{'statuses'}->{$id}->{'reply_last_time'} = $reply_last_time;
			}
		}
	}

	# save the last status created time
	$this->{'public_status'}->{'last_time'} = $last_time;

	return TRUE;
}

sub update_public_status_view {
	my $this = shift;
	my $app = $this->{'app'};

	# get the public status treeview widget
	my $tree_view = $app->get_widget('treeview_public_status');

	# get the public status list store
	my $tree_store = $this->{'public_status_tree_store'};

	# attach the liststore to the treeview
	$tree_view->set_model($tree_store);

	# create the user column
	my $user_column = Gtk2::TreeViewColumn->new();

	# create the user name renderer
	my $user_renderer = Gtk2::CellRendererText->new();
	$user_renderer->set('wrap-mode' => 'word');
	$user_renderer->set('alignment' => 'center');

	# pack the user renderer into the text tree column
	$user_column->pack_start($user_renderer, FALSE);

	# set the user renderer 'text' attribute to column 1 of list store
	$user_column->add_attribute($user_renderer, text => 1);

	# append the user column into the tree view
	$tree_view->append_column($user_column);

	# create the text column
	my $text_column = Gtk2::TreeViewColumn->new();
	$text_column->set('sizing' => 'GTK_TREE_VIEW_COLUMN_FIXED');

	# create the text renderer
	my $text_renderer = Gtk2::CellRendererText->new();
	$text_renderer->set('wrap-mode' => 'word');
	$text_renderer->set('wrap-width' => 300);

	# pack the text renderer into the text tree column
	$text_column->pack_start($text_renderer, FALSE);

	# set the cell renderer 'text' attribute to column 6 of liststore
	$text_column->add_attribute($text_renderer, text => 6);

	# append the text column to the tree view
	$tree_view->append_column($text_column);

	return TRUE;
}

sub move_first_status {
	my $this = shift;
	my $app = $this->{'app'};
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

	my $row = Gtk2::TreePath->new_first;
	$treeview->scroll_to_cell($row);
}

sub expand_all_status {
	my $this = shift;
	my $app = $this->{'app'};
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
	$treeview->expand_all;
}

sub collapse_all_status {
	my $this = shift;
	my $app = $this->{'app'};
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
	$treeview->collapse_all;
}

sub toggle_status_fold {
	my $this = shift;
	my $app = $this->{'app'};
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

	my $tree_selection = $treeview->get_selection;
	my @treepaths = $tree_selection->get_selected_rows;
	if (@treepaths > 0) {
		my $treepath = shift @treepaths;
		if ($treeview->row_expanded($treepath)) {
			$treeview->collapse_row($treepath);
		}
		else {
			$treeview->expand_row($treepath, TRUE);
		}
	}
}

sub set_background_color {
	my ($this, $color) = @_;
	my $app = $this->{'app'};
	my $tree_view;
	my $column;
	my @renderers;
	my $renderer;
	
	# set background color of the freinds status view
	$tree_view = $app->get_widget('treeview_friends_status');
	# column 0
	$column = $tree_view->get_column(0);
	@renderers = $column->get_cell_renderers;
	$renderer = $renderers[0];
	$renderer->set('background-gdk' => $color);
	# column 1
	$column = $tree_view->get_column(1);
	@renderers = $column->get_cell_renderers;
	$renderer = $renderers[0];
	$renderer->set('background-gdk' => $color);
	$tree_view->queue_draw;

	# set background color of my status view
	$tree_view = $app->get_widget('treeview_my_status');
	# column 0
	$column = $tree_view->get_column(0);
	@renderers = $column->get_cell_renderers;
	$renderer = $renderers[0];
	$renderer->set('background-gdk' => $color);
	# column 1
	$column = $tree_view->get_column(1);
	@renderers = $column->get_cell_renderers;
	$renderer = $renderers[0];
	$renderer->set('background-gdk' => $color);
	$tree_view->queue_draw;

	# set background color of the public status view
	$tree_view = $app->get_widget('treeview_public_status');
	# column 0
	$column = $tree_view->get_column(0);
	@renderers = $column->get_cell_renderers;
	$renderer = $renderers[0];
	$renderer->set('background-gdk' => $color);
	# column 1
	$column = $tree_view->get_column(1);
	@renderers = $column->get_cell_renderers;
	$renderer = $renderers[0];
	$renderer->set('background-gdk' => $color);
	$tree_view->queue_draw;
}

sub set_foreground_color {
	my ($this, $color) = @_;
	my $app = $this->{'app'};
	my $tree_view;
	my $column;
	my @renderers;
	my $renderer;
	
	# set background color of the freinds status view
	$tree_view = $app->get_widget('treeview_friends_status');
	# column 0
	$column = $tree_view->get_column(0);
	@renderers = $column->get_cell_renderers;
	$renderer = $renderers[0];
	$renderer->set('foreground-gdk' => $color);
	# column 1
	$column = $tree_view->get_column(1);
	@renderers = $column->get_cell_renderers;
	$renderer = $renderers[0];
	$renderer->set('foreground-gdk' => $color);
	$tree_view->queue_draw;

	# set background color of my status view
	$tree_view = $app->get_widget('treeview_my_status');
	# column 0
	$column = $tree_view->get_column(0);
	@renderers = $column->get_cell_renderers;
	$renderer = $renderers[0];
	$renderer->set('foreground-gdk' => $color);
	# column 1
	$column = $tree_view->get_column(1);
	@renderers = $column->get_cell_renderers;
	$renderer = $renderers[0];
	$renderer->set('foreground-gdk' => $color);
	$tree_view->queue_draw;

	# set background color of the public status view
	$tree_view = $app->get_widget('treeview_public_status');
	# column 0
	$column = $tree_view->get_column(0);
	@renderers = $column->get_cell_renderers;
	$renderer = $renderers[0];
	$renderer->set('foreground-gdk' => $color);
	# column 1
	$column = $tree_view->get_column(1);
	@renderers = $column->get_cell_renderers;
	$renderer = $renderers[0];
	$renderer->set('foreground-gdk' => $color);
	$tree_view->queue_draw;

}

sub set_status_font {
	my ($this, $fontname) = @_;
	my $app = $this->{'app'};
	my $tree_view;
	my $column;
	my @renderers;
	my $renderer;
	
	# set background color of the freinds status view
	$tree_view = $app->get_widget('treeview_friends_status');
	# column 1
	$column = $tree_view->get_column(1);
	@renderers = $column->get_cell_renderers;
	$renderer = $renderers[0];
	$renderer->set('font' => $fontname);
	$tree_view->queue_draw;

	# set background color of my status view
	$tree_view = $app->get_widget('treeview_my_status');
	# column 1
	$column = $tree_view->get_column(1);
	@renderers = $column->get_cell_renderers;
	$renderer = $renderers[0];
	$renderer->set('font' => $fontname);
	$tree_view->queue_draw;

	# set background color of the public status view
	$tree_view = $app->get_widget('treeview_public_status');
	# column 1
	$column = $tree_view->get_column(1);
	@renderers = $column->get_cell_renderers;
	$renderer = $renderers[0];
	$renderer->set('font' => $fontname);
	$tree_view->queue_draw;
}

1; #terminate this package with 1
