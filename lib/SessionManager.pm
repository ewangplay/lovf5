package SessionManager;

# require module
use strict;
use Glib qw(TRUE FALSE);
use Encode qw(decode);

use Global;
use Common;

# construct
sub new {
	my ($class, $app, $f5api, $account) = @_;
	my $this = {};
	$this->{'app'} = $app;
	$this->{'f5api'} = $f5api;
	$this->{'account'} = $account;
	bless $this, $class;
	return $this;
}

sub login {
	my $this = shift;
	my $app = $this->{'app'};
	my $f5api = $this->{'f5api'};
	my $account = $this->{'account'};
	my $verify_success = TRUE;

	# load last time login state
	_loadLoginState($this);

	# initialize login dialog
	my $dlg_login = $app->get_widget('dialog_login');
	my $entry_user = $app->get_widget('entry_user');
	my $entry_password = $app->get_widget('entry_password');
	my $checkbutton_remember_name = $app->get_widget('checkbutton_remember_name');
	my $checkbutton_remember_password = $app->get_widget('checkbutton_remember_password');
	my $checkbutton_auto_login = $app->get_widget('checkbutton_auto_login');
	my $button_login_ok = $app->get_widget('button_login_ok');
	$entry_password->set_visibility(FALSE);	# set password mode
	if ($auto_login) {
		$entry_user->set_text($account->name);
		$entry_password->set_text($account->password);
		$checkbutton_remember_name->set_active(TRUE);
		$checkbutton_remember_password->set_active(TRUE);
		$checkbutton_auto_login->set_active(TRUE);
	}
	elsif ($remember_password) {
		$entry_user->set_text($account->name);
		$entry_password->set_text($account->password);
		$checkbutton_remember_name->set_active(TRUE);
		$checkbutton_remember_password->set_active(TRUE);
	}
	elsif ($remember_name) {
		$entry_user->set_text($account->name);
		$checkbutton_remember_name->set_active(TRUE);
	}

	# show login dialog
	$dlg_login->show;
	if ($auto_login) {
		eval {
			local $SIG{ALRM} = sub { die "auto_login\n" };
			$entry_user->set_sensitive(FALSE);
			$entry_password->set_sensitive(FALSE);
			$button_login_ok->set_sensitive(FALSE);
			
			alarm 2;
			Gtk2->main;
			alarm 0;
		};
		if ($@ eq "auto_login\n") {
			# process auto login
			$login_success = FALSE;

			my $name = $entry_user->get_text();
			my $password = $entry_password->get_text();

			my $user_info = $f5api->getUserInfo(name => $name, password => $password);
			if (!defined($user_info)) {
				MessageBox($dlg_login, 'error',
					decode('utf8', '登录失败，请检查帐户或网络连接！'));

				#verify failed
				$verify_success = FALSE;
			}
			else {
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
			}
		}
	}
	if (!$auto_login || ($auto_login && !$login_success && !$verify_success)) {
		$entry_user->set_sensitive(TRUE);
		$entry_password->set_sensitive(TRUE);
		$button_login_ok->set_sensitive(TRUE);
		Gtk2->main;
	}
	$dlg_login->destroy;

	# save login state
	if ($login_success) {
		_saveLoginState($this);
	}
}

sub logout {
	my $this = shift;
	my $account = $this->{'account'};
	$account->clear;
}

#===================================================================================
#private function
sub _loadLoginState {
	my $this = shift;

	# load login options and user name
	my $login_profile = get_login_profile();
	if (-e $login_profile) {
		my $key_file = Glib::KeyFile->new;
		$key_file->load_from_file($login_profile, 'none');
		$remember_name = $key_file->get_boolean('LOGIN', 'remember_name');
		$remember_password = $key_file->get_boolean('LOGIN', 'remember_password');
		$auto_login = $key_file->get_boolean('LOGIN', 'auto_login');
		$this->{'account'}->name($key_file->get_string('LOGIN', 'name'));
	}

	# load encrypted password
	my $password_profile = get_password_profile();
	if (-e $password_profile) {
		open PROFILE, "<$password_profile";
		my $encrypt_password = <PROFILE>;
		$this->{'account'}->password(decrypt($encrypt_password));
		close PROFILE;
	}

	return TRUE;
}

sub _saveLoginState {
	my $this = shift;
	my $profile_path = get_profile_dir();

	if (-d $profile_path) {
		# save login options and user name
		my $login_profile = get_login_profile();

		my $key_file = Glib::KeyFile->new;

		if (-e $login_profile) {
			$key_file->load_from_file($login_profile, 'none');
		}

		$key_file->set_boolean('LOGIN', 'remember_name', $remember_name);
		$key_file->set_boolean('LOGIN', 'remember_password', $remember_password);
		$key_file->set_boolean('LOGIN', 'auto_login', $auto_login);
		$key_file->set_string('LOGIN', 'name', $this->{'account'}->name);

		my $key_string = $key_file->to_data;

		FileSetContents($login_profile, $key_string);

		# save encrypted password
		my $password_profile = get_password_profile();
		my $encrypt_password = encrypt($this->{'account'}->password);
		FileSetContents($password_profile, $encrypt_password);
	}

	return TRUE;
}

1; #terminate this package with 1
