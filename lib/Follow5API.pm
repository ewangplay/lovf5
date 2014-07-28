package Follow5API;

# require module
use strict;
use Glib qw(TRUE FALSE);
use XML::Simple qw(:strict);

# define constant variant
my $TRANSFER_CMD = 'curl';
my $PUBLIC_STATUS_URL = 'http://api.follow5.com/api/statuses/public_timeline.xml';
my $FRIENDS_STATUS_URL = 'http://api.follow5.com/api/statuses/friends_timeline.xml';
my $USER_STATUS_URL = 'http://api.follow5.com/api/statuses/user_timeline.xml';
my $SPECIFIED_STATUS_URL = 'http://api.follow5.com/api/statuses/show.xml';
my $SUBMIT_STATUS_URL = 'http://api.follow5.com/api/statuses/update.xml';
my $DELETE_STATUS_URL = ' http://api.follow5.com/api/statuses/destroy.xml';
my $FRIENDS_LIST_URL = ' http://api.follow5.com/api/users/friends.xml';
my $FOLLOWERS_LIST_URL = 'http://api.follow5.com/api/users/followers.xml';
my $FOLLOWED_LIST_URL = 'http://api.follow5.com/api/users/followed.xml';
my $USER_INFO_URL = 'http://api.follow5.com/api/users/show.xml';
my $ADD_FRIEND_URL = 'http://api.follow5.com/api/friendships/create.xml';
my $DELETE_FRIEND_URL = ' http://api.follow5.com/api/friendships/destroy.xml';
my $ADD_FOLLOWER_URL = ' http://api.follow5.com/api/follow/create.xml';
my $DELETE_FOLLOWER_URL = 'http://api.follow5.com/api/follow/destroy.xml';
my $IS_FRIEND_URL = 'http://api.follow5.com/api/friendships/exists.xml';
my $IS_FOLLOW_URL = 'http://api.follow5.com/api/follow/exists.xml';
my $USER_VERIFY_URL = 'http://api.follow5.com/api/users/verify_credentials.xml';
my $STATUS_REPLY_URL = 'http://api.follow5.com/api/statuses/reply_timeline.xml';
my $SUBMIT_REPLY_URL = 'http://api.follow5.com/api/statuses/reply.xml';

# construct
sub new {
	my $class = shift;
	my $key = shift;
	my $this = {};
	$this->{'api_key'} = $key;
	bless $this, $class;
	return $this;
}

#=================================================================================
# Share API

# FUNCTION:
#	getPublicStatus([count => value])
# DESCRIPTION:
# 	get the latest status list from all follow5 members.
# PARAM: 
# 	count[optional][integer]: status number, range from 1 to 20, default for 20.
# RETURN:
# 	SUCCESS: return the reference to a HASH struct which contains the retrieved statuses.
#	FAILED: undef
sub getPublicStatus {
	my $this = shift;
	my $api_key = $this->{'api_key'};
	my $count;
	my $refData;

	if (@_ == 0) {	#use default param value
		$count = 20;
	}
	elsif (@_ == 2) {	#use user-defined param value
		my %params = @_;
		for my $key (keys %params) {
			if ($key eq 'count') {
				$count = $params{$key};
			}
			else {
				return undef;
			}
		}
	}
	else {	#param error
		return undef;
	}

	my $xml_string = `$TRANSFER_CMD -d count=$count $PUBLIC_STATUS_URL?api_key=$api_key`;
	if (!defined($xml_string) || $xml_string eq '') {
		return undef;
	}

	$refData = XMLin($xml_string, ForceArray => 1, KeyAttr => '');
	if ($refData eq '') {
		return undef;
	}
	return $refData;
}

# FUNCTION:
#	getFriendsStatus(name => user_name,
#			 password => user_password,
#			 [count => count_value],
#			 [page => page_value])
# DESCRIPTION:
# 	get the related statuses which owned by user or his friends or his follows, etc.
# PARAM: 
#	name[necessary][string]: user name 
#	password[necessary][string]: user password
# 	count[option][integer]: status number, range from 1 to 20, default for 20.
#	page[option][integer]:	page index(1-based), default for 1.
# RETURN:
# 	SUCCESS: return the reference to a HASH struct which contains the retrieved data.
#	FAILED: undef
sub getFriendsStatus { 
	my $this = shift;
	my $api_key = $this->{'api_key'};
	my ($name, $password, $count, $page);
	my $refData;

	if (@_ == 4) {
		my %params = @_;
		for my $key (keys %params) {
			if ($key eq 'name') {
				$name = $params{$key};
			}
			elsif ($key eq 'password') {
				$password = $params{$key};
			}
			else {
				return undef;
			}
		}

		# set default value
		$count = 20;
		$page = 1;
	}
	elsif (@_ == 6) {
		my %params = @_;
		my $set_count = FALSE;
		my $set_page = FALSE;
		for my $key (keys %params) {
			if ($key eq 'name') {
				$name = $params{$key};
			}
			elsif ($key eq 'password') {
				$password = $params{$key};
			}
			elsif ($key eq 'count') {
				$count = $params{$key};
				$set_count = TRUE;
			}
			elsif ($key eq 'page') {
				$page = $params{$key};
				$set_page = TRUE;
			}
			else {
				return undef;
			}
		}

		# set default value
		if (not $set_count) {
			$count = 20;
		}
		if (not $set_page) {
			$page = 1;
		}
	}
	elsif (@_ == 8) {
		my %params = @_;
		for my $key (keys %params) {
			if ($key eq 'name') {
				$name = $params{$key};
			}
			elsif ($key eq 'password') {
				$password = $params{$key};
			}
			elsif ($key eq 'count') {
				$count = $params{$key};
			}
			elsif ($key eq 'page') {
				$page = $params{$key};
			}
			else {
				return undef;
			}
		}
	}
	else {	#params error
		return undef;
	}

	my $xml_string = `$TRANSFER_CMD -u $name:$password -d count=$count -d page=$page $FRIENDS_STATUS_URL?api_key=$api_key`;
	if (!defined($xml_string) || $xml_string eq '') {
		return undef;
	}

	$refData = XMLin($xml_string, ForceArray => 1, KeyAttr => '');
	if ($refData eq '') {
		return undef;
	}
	return $refData;
}

# FUNCTION:
#	getUserStatus(
#		name => user_name,
#		password => user_password,
#		[count => count_value,]
#		[page => page_value])
# DESCRIPTION:
# 	get the user's status.
# PARAM: 
#	name[necessary][string]: user name 
#	password[necessary][string]: user password
# 	count[option][integer]: status number, range from 1 to 20, default for 20.
#	page[option][integer]:	page index(1-based), default for 1.
# RETURN:
# 	SUCCESS: return the reference to a HASH struct which contains the retrieved data.
#	FAILED: undef
sub getUserStatus {
	my $this = shift;
	my $api_key = $this->{'api_key'};
	my ($name, $password, $count, $page);
	my $refData;

	if (@_ == 4) {
		my %params = @_;
		for my $key (keys %params) {
			if ($key eq 'name') {
				$name = $params{$key};
			}
			elsif ($key eq 'password') {
				$password = $params{$key};
			}
			else {
				return undef;
			}
		}

		# set default value
		$count = 20;
		$page = 1;
	}
	elsif (@_ == 6) {
		my %params = @_;
		my $set_count = FALSE;
		my $set_page = FALSE;
		for my $key (keys %params) {
			if ($key eq 'name') {
				$name = $params{$key};
			}
			elsif ($key eq 'password') {
				$password = $params{$key};
			}
			elsif ($key eq 'count') {
				$count = $params{$key};
				$set_count = TRUE;
			}
			elsif ($key eq 'page') {
				$page = $params{$key};
				$set_page = TRUE;
			}
			else {
				return undef;
			}
		}

		# set default value
		if (not $set_count) {
			$count = 20;
		}
		if (not $set_page) {
			$page = 1;
		}
	}
	elsif (@_ == 8) {
		my %params = @_;
		for my $key (keys %params) {
			if ($key eq 'name') {
				$name = $params{$key};
			}
			elsif ($key eq 'password') {
				$password = $params{$key};
			}
			elsif ($key eq 'count') {
				$count = $params{$key};
			}
			elsif ($key eq 'page') {
				$page = $params{$key};
			}
			else {
				return undef;
			}
		}
	}
	else {	#params error
		return undef;
	}

	my $xml_string = `$TRANSFER_CMD -u $name:$password -d count=$count -d page=$page $USER_STATUS_URL?api_key=$api_key`;
	if (!defined($xml_string) || $xml_string eq '') {
		return undef;
	}

	$refData = XMLin($xml_string, ForceArray => 1, KeyAttr => '');
	if ($refData eq '') {
		return undef;
	}
	return $refData;

}

# FUNCTION:
#	getSpecifiedStatus(id => status_id);
# DESCRIPTION:
# 	get the specified status via status id.
# PARAM: 
# 	id[necessary][string]:	status id
# RETURN:
# 	SUCCESS: return the reference to a HASH struct which contains the retrieved data.
#	FAILED: undef
sub getSpecifiedStatus {
	my $this = shift;
	my $api_key = $this->{'api_key'};
	my $id;
	my $refData;

	# parse params
	if(@_ == 2) {
		my %params = @_;
		for my $key (keys %params) {
			if ($key eq 'id') {
				$id = $params{$key};
			}
			else {
				return undef;
			}
		}
	}
	else {
		return undef;
	}

	# excute follow5 api and get xml format result 
	my $xml_string = `$TRANSFER_CMD -d id=$id SPECIFIED_STATUS_URL?api_key=$api_key`;
	if (!defined($xml_string) || $xml_string eq '') {
		return undef;
	}

	# convert xml format result to perl HASH format data and return
	$refData = XMLin($xml_string, ForceArray => 1, KeyAttr => '');
	if ($refData eq '') {
		return undef;
	}
	return $refData;
}

# FUNCTION:
#	submitStatus(
#		name => user_name,
#		password = user_password,
#		status => status_text,
#		[link => link_text,]
#		[source => source_text])
# DESCRIPTION:
# 	submit new status
# PARAM: 
#	name[necessary][string]: user name 
#	password[necessary][string]: user password
# 	status[necessary][string]: status content, utf-8 encoding.
# 	link[optional][string]: status link, utf-8 encoding, could be image, music,
# 				vedio url link.
# 	source[optional][string]: status source, eg. msn, qq, gtalk, etc.
# RETURN:
# 	SUCCESS: reference to the HASH struct with contains the new status
# 	FAILED: undef
sub submitStatus {
	my $this = shift;
	my $api_key = $this->{'api_key'};
	my ($name, $password, $status, $link, $source);
	my $refData;
	my $set_link = FALSE;
	my $set_source = FALSE;

	# parse params
	if (@_ == 6) {
		my %params = @_;
		for my $key (keys %params) {
			if ($key eq 'name') {
				$name = $params{$key};
			}
			elsif ($key eq 'password') {
				$password = $params{$key};
			}
			elsif ($key eq 'status') {
				$status = $params{$key};
			}
			else {
				return undef;
			}
		}
	}
	elsif (@_ == 8 or @_ == 10) {
		my %params = @_;
		for my $key (keys %params) {
			if ($key eq 'name') {
				$name = $params{$key};
			}
			elsif ($key eq 'password') {
				$password = $params{$key};
			}
			elsif ($key eq 'status') {
				$status = $params{$key};
			}
			elsif ($key eq 'link') {
				$link = $params{$key};
				$set_link = TRUE;
			}
			elsif ($key eq 'source') {
				$source = $params{$key};
				$set_source = TRUE;
			}
			else {
				return undef;
			}
		}
	}
	else {
		return undef;
	}

	# execute f5 api and get xml string
	my $xml_string;
	if ($set_link and $set_source) {
		$xml_string = `$TRANSFER_CMD -u $name:$password -d status="$status" -d link="$link" -d source="$source" $SUBMIT_STATUS_URL?api_key=$api_key`;
	}
	elsif ($set_link) {
		$xml_string = `$TRANSFER_CMD -u $name:$password -d status="$status" -d link="$link" $SUBMIT_STATUS_URL?api_key=$api_key`;
	}
	elsif ($set_source) {
		$xml_string = `$TRANSFER_CMD -u $name:$password -d status="$status" -d source="$source" $SUBMIT_STATUS_URL?api_key=$api_key`;
	}
	else {
		$xml_string = `$TRANSFER_CMD -u $name:$password -d status="$status" $SUBMIT_STATUS_URL?api_key=$api_key`;
	}

	if (!defined($xml_string) || $xml_string eq '') {
		return undef;
	}

	# convert xml string to HASH struct
	$refData = XMLin($xml_string, ForceArray => 1, KeyAttr => '');
	if ($refData eq '') {
		return undef;
	}
	return $refData;
}

# FUNCTION:
#	deleteStatus(
#		name => user_name,
#		password => user_password,
#		id = status_id,
#		)
# DESCRIPTION:
# 	delete the specifed status.
# PARAM: 
#	name[necessary][string]: user name
#	password[necessary][string]: user password
# 	id[necessary][string]: status id
# RETURN:
# 	TRUE: sucess
# 	FALSE: failed
sub deleteStatus {
	my $this = shift;
	my $api_key = $this->{'api_key'};
	my ($name, $password, $id);

	# parse params
	if(@_ == 6) {
		my %params = @_;
		for my $key (keys %params) {
			if ($key eq 'name') {
				$name = $params{$key};
			}
			elsif ($key eq 'password') {
				$password = $params{$key};
			}
			elsif ($key eq 'id') {
				$id = $params{$key};
			}
			else {
				return FALSE;
			}
		}
	}
	else {
		return FALSE;
	}

	# execute follow5 api and get xml format result
	my $xml_string = `$TRANSFER_CMD -u $name:$password -d id=$id $DELETE_STATUS_URL?api_key=$api_key`;
	if (!defined($xml_string) || $xml_string eq '') {
		return undef;
	}

	my $refData = XMLin($xml_string, ForceArray => 1, KeyAttr => '');
	if ($refData eq '') {
		return FALSE;
	}
	
	if (!($refData eq 'true')) {
		return FALSE;
	}

	return TRUE;
}

#==================================================================================
# User API

# FUNCTION:
#	getFriendsList(
#		name => user_name,
#		password => user_password,
#		[count => count_value,]
#		[page => page_value])
# DESCRIPTION:
# 	get the user's friends list via user name.
# PARAM: 
#	name[necessary][string]: user name 
#	password[necessary][string]: user password
# 	count[option][integer]: status number, range from 1 to 20, default for 20.
#	page[option][integer]:	page index(1-based), default for 1.
# RETURN:
# 	SUCCESS: return the reference to a HASH struct which contains the retrieved data.
#	FAILED: undef
sub getFriendsList {
	my $this = shift;
	my $api_key = $this->{'api_key'};
	my ($name, $password, $count, $page);
	my $refData;

	if (@_ == 4) {
		my %params = @_;
		for my $key (keys %params) {
			if ($key eq 'name') {
				$name = $params{$key};
			}
			elsif ($key eq 'password') {
				$password = $params{$key};
			}
			else {
				return undef;
			}
		}

		# set default value
		$count = 20;
		$page = 1;
	}
	elsif (@_ == 6) {
		my %params = @_;
		my $set_count = FALSE;
		my $set_page = FALSE;
		for my $key (keys %params) {
			if ($key eq 'name') {
				$name = $params{$key};
			}
			elsif ($key eq 'password') {
				$password = $params{$key};
			}
			elsif ($key eq 'count') {
				$count = $params{$key};
				$set_count = TRUE;
			}
			elsif ($key eq 'page') {
				$page = $params{$key};
				$set_page = TRUE;
			}
			else {
				return undef;
			}
		}

		# set default value
		if (not $set_count) {
			$count = 20;
		}
		if (not $set_page) {
			$page = 1;
		}
	}
	elsif (@_ == 8) {
		my %params = @_;
		for my $key (keys %params) {
			if ($key eq 'name') {
				$name = $params{$key};
			}
			elsif ($key eq 'password') {
				$password = $params{$key};
			}
			elsif ($key eq 'count') {
				$count = $params{$key};
			}
			elsif ($key eq 'page') {
				$page = $params{$key};
			}
			else {
				return undef;
			}
		}
	}
	else {	#params error
		return undef;
	}

	my $xml_string = `$TRANSFER_CMD -u $name:$password -d count=$count -d page=$page $FRIENDS_LIST_URL?api_key=$api_key`;
	if (!defined($xml_string) || $xml_string eq '') {
		return undef;
	}

	$refData = XMLin($xml_string, ForceArray => 1, KeyAttr => '');
	if ($refData eq '') {
		return undef;
	}
	return $refData;
}

# FUNCTION:
#	getFriendsList_via_id(
#		id => user_id,
#		[count => count_value,]
#		[page => page_value])
# DESCRIPTION:
# 	get the user's friends list via user id.
# PARAM: 
#	id[necessary][string]: user id
# 	count[option][integer]: status number, range from 1 to 20, default for 20.
#	page[option][integer]:	page index(1-based), default for 1.
# RETURN:
# 	SUCCESS: return the reference to a HASH struct which contains the retrieved data.
#	FAILED: undef
sub getFriendsList_via_id {
	my $this = shift;
	my $api_key = $this->{'api_key'};
	my ($id, $count, $page);
	my $refData;

	if (@_ == 2) {
		my %params = @_;
		for my $key (keys %params) {
			if ($key eq 'id') {
				$id = $params{$key};
			}
			else {
				return undef;
			}
		}

		# set default value
		$count = 20;
		$page = 1;
	}
	elsif (@_ == 4) {
		my %params = @_;
		my $set_count = FALSE;
		my $set_page = FALSE;
		for my $key (keys %params) {
			if ($key eq 'id') {
				$id = $params{$key};
			}
			elsif ($key eq 'count') {
				$count = $params{$key};
				$set_count = TRUE;
			}
			elsif ($key eq 'page') {
				$page = $params{$key};
				$set_page = TRUE;
			}
			else {
				return undef;
			}
		}

		# set default value
		if (not $set_count) {
			$count = 20;
		}
		if (not $set_page) {
			$page = 1;
		}
	}
	elsif (@_ == 6) {
		my %params = @_;
		for my $key (keys %params) {
			if ($key eq 'id') {
				$id = $params{$key};
			}
			elsif ($key eq 'count') {
				$count = $params{$key};
			}
			elsif ($key eq 'page') {
				$page = $params{$key};
			}
			else {
				return undef;
			}
		}
	}
	else {	#params error
		return undef;
	}

	my $xml_string = `$TRANSFER_CMD -d id=$id -d count=$count -d page=$page $FRIENDS_LIST_URL?api_key=$api_key`;
	if (!defined($xml_string) || $xml_string eq '') {
		return undef;
	}

	$refData = XMLin($xml_string, ForceArray => 1, KeyAttr => '');
	if ($refData eq '') {
		return undef;
	}
	return $refData;
}


# FUNCTION:
#	getFollowsList(
#		name => user_name,
#		password => user_password,
#		[count => count_value,]
#		[page => page_value])
# DESCRIPTION:
#	get follow members list.
# PARAM: 
#	name[necessary][string]: user name 
#	password[necessary][string]: user password
# 	count[option][integer]: status number, range from 1 to 20, default for 20.
#	page[option][integer]:	page index(1-based), default for 1.
# RETURN:
# 	SUCCESS: return the reference to a HASH struct which contains the retrieved data.
#	FAILED: undef
sub getFollowsList {
	my $this = shift;
	my $api_key = $this->{'api_key'};
	my ($name, $password, $count, $page);
	my $refData;

	if (@_ == 4) {
		my %params = @_;
		for my $key (keys %params) {
			if ($key eq 'name') {
				$name = $params{$key};
			}
			elsif ($key eq 'password') {
				$password = $params{$key};
			}
			else {
				return undef;
			}
		}

		# set default value
		$count = 20;
		$page = 1;
	}
	elsif (@_ == 6) {
		my %params = @_;
		my $set_count = FALSE;
		my $set_page = FALSE;
		for my $key (keys %params) {
			if ($key eq 'name') {
				$name = $params{$key};
			}
			elsif ($key eq 'password') {
				$password = $params{$key};
			}
			elsif ($key eq 'count') {
				$count = $params{$key};
				$set_count = TRUE;
			}
			elsif ($key eq 'page') {
				$page = $params{$key};
				$set_page = TRUE;
			}
			else {
				return undef;
			}
		}

		# set default value
		if (not $set_count) {
			$count = 20;
		}
		if (not $set_page) {
			$page = 1;
		}
	}
	elsif (@_ == 8) {
		my %params = @_;
		for my $key (keys %params) {
			if ($key eq 'name') {
				$name = $params{$key};
			}
			elsif ($key eq 'password') {
				$password = $params{$key};
			}
			elsif ($key eq 'count') {
				$count = $params{$key};
			}
			elsif ($key eq 'page') {
				$page = $params{$key};
			}
			else {
				return undef;
			}
		}
	}
	else {	#params error
		return undef;
	}

	my $xml_string = `$TRANSFER_CMD -u $name:$password -d count=$count -d page=$page $FOLLOWERS_LIST_URL?api_key=$api_key`;
	if (!defined($xml_string) || $xml_string eq '') {
		return undef;
	}

	$refData = XMLin($xml_string, ForceArray => 1, KeyAttr => '');
	if ($refData eq '') {
		return undef;
	}
	return $refData;

}

# FUNCTION:
#	getFollowsList_via_id(
#		id => user_id,
#		[count => count_value,]
#		[page => page_value])
# DESCRIPTION:
#	get follow members list via id.
# PARAM: 
#	id[necessary][string]: user id
# 	count[option][integer]: status number, range from 1 to 20, default for 20.
#	page[option][integer]:	page index(1-based), default for 1.
# RETURN:
# 	SUCCESS: return the reference to a HASH struct which contains the retrieved data.
#	FAILED: undef
sub getFollowsList_via_id {
	my $this = shift;
	my $api_key = $this->{'api_key'};
	my ($id, $count, $page);
	my $refData;

	if (@_ == 2) {
		my %params = @_;
		for my $key (keys %params) {
			if ($key eq 'id') {
				$id = $params{$key};
			}
			else {
				return undef;
			}
		}

		# set default value
		$count = 20;
		$page = 1;
	}
	elsif (@_ == 4) {
		my %params = @_;
		my $set_count = FALSE;
		my $set_page = FALSE;
		for my $key (keys %params) {
			if ($key eq 'id') {
				$id = $params{$key};
			}
			elsif ($key eq 'count') {
				$count = $params{$key};
				$set_count = TRUE;
			}
			elsif ($key eq 'page') {
				$page = $params{$key};
				$set_page = TRUE;
			}
			else {
				return undef;
			}
		}

		# set default value
		if (not $set_count) {
			$count = 20;
		}
		if (not $set_page) {
			$page = 1;
		}
	}
	elsif (@_ == 6) {
		my %params = @_;
		for my $key (keys %params) {
			if ($key eq 'id') {
				$id = $params{$key};
			}
			elsif ($key eq 'count') {
				$count = $params{$key};
			}
			elsif ($key eq 'page') {
				$page = $params{$key};
			}
			else {
				return undef;
			}
		}
	}
	else {	#params error
		return undef;
	}

	my $xml_string = `$TRANSFER_CMD -d id=$id -d count=$count -d page=$page $FOLLOWERS_LIST_URL?api_key=$api_key`;
	if (!defined($xml_string) || $xml_string eq '') {
		return undef;
	}

	$refData = XMLin($xml_string, ForceArray => 1, KeyAttr => '');
	if ($refData eq '') {
		return undef;
	}
	return $refData;

}

# FUNCTION:
#	getFollowedList(
#		name => user_name,
#		password => user_password,
#		[count => count_value,]
#		[page => page_value])
# DESCRIPTION:
# 	get the members list who follow the specified user.
# PARAM: 
#	name[necessary][string]: user name 
#	password[necessary][string]: user password
# 	count[option][integer]: status number, range from 1 to 20, default for 20.
#	page[option][integer]:	page index(1-based), default for 1.
# RETURN:
# 	SUCCESS: return the reference to a HASH struct which contains the retrieved data.
#	FAILED: undef
sub getFollowedList {
	my $this = shift;
	my $api_key = $this->{'api_key'};
	my ($name, $password, $count, $page);
	my $refData;

	if (@_ == 4) {
		my %params = @_;
		for my $key (keys %params) {
			if ($key eq 'name') {
				$name = $params{$key};
			}
			elsif ($key eq 'password') {
				$password = $params{$key};
			}
			else {
				return undef;
			}
		}

		# set default value
		$count = 20;
		$page = 1;
	}
	elsif (@_ == 6) {
		my %params = @_;
		my $set_count = FALSE;
		my $set_page = FALSE;
		for my $key (keys %params) {
			if ($key eq 'name') {
				$name = $params{$key};
			}
			elsif ($key eq 'password') {
				$password = $params{$key};
			}
			elsif ($key eq 'count') {
				$count = $params{$key};
				$set_count = TRUE;
			}
			elsif ($key eq 'page') {
				$page = $params{$key};
				$set_page = TRUE;
			}
			else {
				return undef;
			}
		}

		# set default value
		if (not $set_count) {
			$count = 20;
		}
		if (not $set_page) {
			$page = 1;
		}
	}
	elsif (@_ == 8) {
		my %params = @_;
		for my $key (keys %params) {
			if ($key eq 'name') {
				$name = $params{$key};
			}
			elsif ($key eq 'password') {
				$password = $params{$key};
			}
			elsif ($key eq 'count') {
				$count = $params{$key};
			}
			elsif ($key eq 'page') {
				$page = $params{$key};
			}
			else {
				return undef;
			}
		}
	}
	else {	#params error
		return undef;
	}

	my $xml_string = `$TRANSFER_CMD -u $name:$password -d count=$count -d page=$page $FOLLOWED_LIST_URL?api_key=$api_key`;
	if (!defined($xml_string) || $xml_string eq '') {
		return undef;
	}

	$refData = XMLin($xml_string, ForceArray => 1, KeyAttr => '');
	if ($refData eq '') {
		return undef;
	}
	return $refData;
}

# FUNCTION:
#	getFollowedList_via_id(
#		id => user_id,
#		[count => count_value,]
#		[page => page_value])
# DESCRIPTION:
# 	get the members list who follow the specified user via user id.
# PARAM: 
#	id[necessary][string]: user id.
# 	count[option][integer]: status number, range from 1 to 20, default for 20.
#	page[option][integer]:	page index(1-based), default for 1.
# RETURN:
# 	SUCCESS: return the reference to a HASH struct which contains the retrieved data.
#	FAILED: undef
sub getFollowedList_via_id {
	my $this = shift;
	my $api_key = $this->{'api_key'};
	my ($id, $count, $page);
	my $refData;

	if (@_ == 2) {
		my %params = @_;
		for my $key (keys %params) {
			if ($key eq 'id') {
				$id = $params{$key};
			}
			else {
				return undef;
			}
		}

		# set default value
		$count = 20;
		$page = 1;
	}
	elsif (@_ == 4) {
		my %params = @_;
		my $set_count = FALSE;
		my $set_page = FALSE;
		for my $key (keys %params) {
			if ($key eq 'id') {
				$id = $params{$key};
			}
			elsif ($key eq 'count') {
				$count = $params{$key};
				$set_count = TRUE;
			}
			elsif ($key eq 'page') {
				$page = $params{$key};
				$set_page = TRUE;
			}
			else {
				return undef;
			}
		}

		# set default value
		if (not $set_count) {
			$count = 20;
		}
		if (not $set_page) {
			$page = 1;
		}
	}
	elsif (@_ == 6) {
		my %params = @_;
		for my $key (keys %params) {
			if ($key eq 'id') {
				$id = $params{$key};
			}
			elsif ($key eq 'count') {
				$count = $params{$key};
			}
			elsif ($key eq 'page') {
				$page = $params{$key};
			}
			else {
				return undef;
			}
		}
	}
	else {	#params error
		return undef;
	}

	my $xml_string = `$TRANSFER_CMD -d id=$id -d count=$count -d page=$page $FOLLOWED_LIST_URL?api_key=$api_key`;
	if (!defined($xml_string) || $xml_string eq '') {
		return undef;
	}

	$refData = XMLin($xml_string, ForceArray => 1, KeyAttr => '');
	if ($refData eq '') {
		return undef;
	}
	return $refData;
}

# FUNCTION:
#	getUserInfo(name => user_name, password => user_password)
# DESCRIPTION:
# 	get the specified user's information via user name.
# PARAM: 
#	name[necessary][string]: user name
#	password[necessary][string]: user password
# RETURN:
# 	SUCESS: return the reference to a HASH struct which contains the retrieved data.
#	FAILED: undef
sub getUserInfo {
	my $this = shift;
	my $api_key = $this->{'api_key'};
	my ($name, $password);
	my $refData;

	# parse params
	if (@_ == 4) {
		my %params = @_;
		for my $key (keys %params) {
			if ($key eq 'name') {
				$name = $params{$key};
			}
			elsif ($key eq 'password') {
				$password = $params{$key};
			}
			else {
				return undef;
			}
		}
	}
	else {
		return undef;
	}

	# execute f5 api and get xml format result
	my $xml_string = `$TRANSFER_CMD -u $name:$password $USER_INFO_URL?api_key=$api_key`;

	if (!defined($xml_string) || $xml_string eq '') {
		return undef;
	}

	# convert xml format data to perl HASH struct
	$refData = XMLin($xml_string, ForceArray => 1, KeyAttr => '');

	if ($refData eq '') {
		return undef;
	}
	return $refData;
}

# FUNCTION:
#	getUserInfo_via_id(id => user_id)
# DESCRIPTION:
# 	get the specified user's information via user id.
# PARAM: 
#	id[necessary][string]: user id.
# RETURN:
# 	SUCESS: return the reference to a HASH struct which contains the retrieved data.
#	FAILED: undef
sub getUserInfo_via_id {
	my $this = shift;
	my $api_key = $this->{'api_key'};
	my $id;
	my $refData;

	# parse params
	if (@_ == 2) {
		my %params = @_;
		for my $key (keys %params) {
			if ($key eq 'id') {
				$id = $params{$key};
			}
			else {
				return undef;
			}
		}
	}
	else {
		return undef;
	}

	# execute f5 api and get xml format result
	my $xml_string = `$TRANSFER_CMD -d id=$id $USER_INFO_URL?api_key=$api_key`;
	if (!defined($xml_string) || $xml_string eq '') {
		return undef;
	}

	# convert xml format data to perl HASH struct
	$refData = XMLin($xml_string, ForceArray => 1, KeyAttr => '');
	if ($refData eq '') {
		return undef;
	}
	return $refData;
}

# FUNCTION:
#	addFriend(
#		name => user_name,
#		password => user_password,
#		id => friend_id
#		)
# DESCRIPTION:
# 	add friend via user id.
# PARAM: 
#	name[necessary][string]: user name
#	password[necessary][string]: user password
# 	id[necessary][string]: friend id to be added.
# RETURN:
# 	TRUE: seccess
# 	FALSE: failed
sub addFriend {
	my $this = shift;
	my $api_key = $this->{'api_key'};
	my ($name, $password, $id);
	my $add_success;

	# parse params
	if (@_ == 6) {
		my %params = @_;
		for my $key (keys %params) {
			if ($key eq 'name') {
				$name = $params{$key};
			}
			elsif ($key eq 'password') {
				$password = $params{$key};
			}
			elsif ($key eq 'id') {
				$id = $params{$key};
			}
			else {
				return FALSE;
			}
		}
	}
	else {
		return FALSE;
	}

	my $xml_string = `$TRANSFER_CMD -u $name:$password -d id=$id $ADD_FRIEND_URL?api_key=$api_key`;
	if (!defined($xml_string) || $xml_string eq '') {
		return FALSE;
	}

	my $refData = XMLin($xml_string, ForceArray => 1, KeyAttr => '');
	if ($refData eq '') {
		return FALSE;
	}

	# parse result

	return $add_success;
}

# FUNCTION:
#	deleteFriend(
#		name => user_name,
#		password => user_password,
#		id => friend_id
#		)
# DESCRIPTION:
# 	delete the specified firend via user id.
# PARAM: 
#	name[necessary][string]: user name
#	password[necessary][string]: user password
# 	id[necessary][string]: friend id to be added.
# RETURN:
# 	TRUE: success
# 	FALSE: failed
sub deleteFriend {
	my $this = shift;
	my $api_key = $this->{'api_key'};
	my ($name, $password, $id);

	# parse params
	if (@_ == 6) {
		my %params = @_;
		for my $key (keys %params) {
			if ($key eq 'name') {
				$name = $params{$key};
			}
			elsif ($key eq 'password') {
				$password = $params{$key};
			}
			elsif ($key eq 'id') {
				$id = $params{$key};
			}
			else {
				return FALSE;
			}
		}
	}
	else {
		return FALSE;
	}

	my $xml_string = `$TRANSFER_CMD -u $name:$password -d id=$id $DELETE_FRIEND_URL?api_key=$api_key`;
	if (!defined($xml_string) || $xml_string eq '') {
		return FALSE;
	}

	my $refData = XMLin($xml_string, ForceArray => 1, KeyAttr => '');
	if ($refData eq '') {
		return FALSE;
	}

	if (!($refData eq 'true')) {
		return FALSE;
	}

	return TRUE;
}

# FUNCTION:
#	followUser(
#		name => user_name,
#		password => user_password,
#		id => friend_id
#		)
# DESCRIPTION:
# 	follow the specified user via user id.
# PARAM: 
#	name[necessary][string]: user name
#	password[necessary][string]: user password
# 	id[necessary][string]: friend id to be added.
# RETURN:
# 	TRUE: success
# 	FALSE: failed
sub followUser {
	my $this = shift;
	my $api_key = $this->{'api_key'};
	my ($name, $password, $id);
	my $follow_success;

	# parse params
	if (@_ == 6) {
		my %params = @_;
		for my $key (keys %params) {
			if ($key eq 'name') {
				$name = $params{$key};
			}
			elsif ($key eq 'password') {
				$password = $params{$key};
			}
			elsif ($key eq 'id') {
				$id = $params{$key};
			}
			else {
				return FALSE;
			}
		}
	}
	else {
		return FALSE;
	}

	my $xml_string = `$TRANSFER_CMD -u $name:$password -d id=$id $ADD_FOLLOWER_URL?api_key=$api_key`;
	if (!defined($xml_string) || $xml_string eq '') {
		return FALSE;
	}

	my $refData = XMLin($xml_string, ForceArray => 1, KeyAttr => '');
	if ($refData eq '') {
		return FALSE;
	}

	# parse result

	return $follow_success;

}

# FUNCTION:
#	cancelFollowUser(
#		name => user_name,
#		password => user_password,
#		id => friend_id
#		)
# DESCRIPTION:
# 	cancel to follow the specified user via user id.
# PARAM: 
#	name[necessary][string]: user name
#	password[necessary][string]: user password
# 	id[necessary][string]: friend id to be added.
# RETURN:
# 	TRUE: success
# 	FALSE: failed
sub cancelFollowUser {
	my $this = shift;
	my $api_key = $this->{'api_key'};
	my ($name, $password, $id);
	my $cancel_success;

	# parse params
	if (@_ == 6) {
		my %params = @_;
		for my $key (keys %params) {
			if ($key eq 'name') {
				$name = $params{$key};
			}
			elsif ($key eq 'password') {
				$password = $params{$key};
			}
			elsif ($key eq 'id') {
				$id = $params{$key};
			}
			else {
				return FALSE;
			}
		}
	}
	else {
		return FALSE;
	}

	my $xml_string = `$TRANSFER_CMD -u $name:$password -d id=$id $DELETE_FOLLOWER_URL?api_key=$api_key`;
	if (!defined($xml_string) || $xml_string eq '') {
		return FALSE;
	}

	my $refData = XMLin($xml_string, ForceArray => 1, KeyAttr => '');
	if ($refData eq '') {
		return FALSE;
	}

	# parse result

	return $cancel_success;


}

# FUNCTION:
#	isFriend(
#		id => user_id,
#		fid => friend_id
#		)
# DESCRIPTION:
# 	determine if the specified two users are friend.
# PARAM: 
# 	id[necessary][string]: the first user id
# 	fid[necessary][string]: the second user id
# RETURN:
# 	TRUE: friend
# 	FALSE: no friend
sub isFriend {
	my $this = shift;
	my $api_key = $this->{'api_key'};
	my ($id, $fid);
	my $is_friend;

	# parse params
	if (@_ == 4) {
		my %params = @_;
		for my $key (keys %params) {
			if ($key eq 'id') {
				$id = $params{$key};
			}
			elsif ($key eq 'fid') {
				$fid = $params{$key};
			}
			else {
				return FALSE;
			}
		}
	}
	else {
		return FALSE;
	}

	my $xml_string = `$TRANSFER_CMD -d id=$id -d fid=$fid $IS_FRIEND_URL?api_key=$api_key`;
	if (!defined($xml_string) || $xml_string eq '') {
		return FALSE;
	}

	my $refData = XMLin($xml_string, ForceArray => 1, KeyAttr => '');
	if ($refData eq '') {
		return FALSE;
	}

	# parse result 
	#
	return $is_friend;
}

# FUNCTION:
#	isFollowed(
#		id => user_id,
#		fid => follow_id
#		)
# DESCRIPTION:
# 	determine if the specified two users are follow relation
# PARAM: 
# 	id[necessary][string]: the first user id
# 	fid[necessary][string]: the second user id
# RETURN:
# 	TRUE: follow relation
# 	FALSE: no follow relation
sub isFollowed {
	my $this = shift;
	my $api_key = $this->{'api_key'};
	my ($id, $fid);
	my $is_follow;

	# parse params
	if (@_ == 4) {
		my %params = @_;
		for my $key (keys %params) {
			if ($key eq 'id') {
				$id = $params{$key};
			}
			elsif ($key eq 'fid') {
				$fid = $params{$key};
			}
			else {
				return FALSE;
			}
		}
	}
	else {
		return FALSE;
	}

	my $xml_string = `$TRANSFER_CMD -d id=$id -d fid=$fid $IS_FOLLOW_URL?api_key=$api_key`;
	if (!defined($xml_string) || $xml_string eq '') {
		return FALSE;
	}

	my $refData = XMLin($xml_string, ForceArray => 1, KeyAttr => '');
	if ($refData eq '') {
		return FALSE;
	}

	# parse result 
	#
	return $is_follow;

}

#=================================================================================
# User Account Verify API

# FUNCTION:
#	userVerify
# DESCRIPTION:
# 	verify the user account if it is valid.
# PARAM: 
# 	username[necessary][string]: user name
# 	password[necessary][string]: user password
# RETURN:
# 	TRUE: the account is valid
# 	FALSE: the account is not valid
sub userVerify{
	my $this = shift;
	my ($username, $password) = @_;
	my $api_key = $this->{'api_key'};

	my $xml_string = `$TRANSFER_CMD -u $username:$password $USER_VERIFY_URL?api_key=$api_key`;
	if (!defined($xml_string) || $xml_string eq '') {
		return FALSE;
	}

	my $refData = XMLin($xml_string, ForceArray => 1, KeyAttr => '');
	if ($refData eq '') {
		return FALSE;
	}
	
	return TRUE;
}


#=================================================================================
# User Reply API

# FUNCTION:
#	getStatusReply(id => status_id)
# DESCRIPTIPN:
# 	get the specified status's repleies.
# PARAM: 
# 	id[necessary][string]: status id
# RETURN:
# 	SUCCESS: return the reference to a HASH struct which contains the retrieved data.
#	FAILED: undef
sub getStatusReply {
	my $this = shift;
	my $api_key = $this->{'api_key'};
	my $id;

	if (@_ ==2) {
		my %params = @_;
		for my $key (keys %params) {
			if ($key eq 'id') {
				$id = $params{$key};
			}
			else {
				return undef;
			}
		}
	}
	else {
		return undef;
	}

	my $xml_string = `$TRANSFER_CMD -d id=$id $STATUS_REPLY_URL?api_key=$api_key`;
	if (!defined($xml_string) || $xml_string eq '') {
		return undef;
	}
	
	my $refData = XMLin($xml_string, ForceArray => 1, KeyAttr => '');
	if ($refData eq '') {
		return undef;
	}
	return $refData;
}

# FUNCTION:
#	submitStatusReply(
#		name => user_name,
#		password => user_password,
#		id => status_id,
#		status => reply_text,
#		source => reply_source);
# DESCRIPTION:
# 	submit new reply for the specified status.
# PARAM: 
#	name[necessary][string]: user name
#	password[necessary][string]: user password
# 	id[necessary][string]: status id
# 	status[neccessary][string]: reply content, utf-8 encoding
# 	source[optional][string]: reply source, eg. msn, qq, gtalk, etc.
# RETURN:
# 	SUCCESS: return the reference to a HASH struct which contains the retrieved data.
#	FAILED: undef

sub submitStatusReply {
	my $this = shift;
	my $api_key = $this->{'api_key'};
	my ($name, $password, $id, $status, $source);
	my $refData;
	my $set_source = FALSE;

	# parse params
	if (@_ == 8) {
		my %params = @_;
		for my $key (keys %params) {
			if ($key eq 'name') {
				$name = $params{$key};
			}
			elsif ($key eq 'password') {
				$password = $params{$key};
			}
			elsif ($key eq 'id') {
				$id = $params{$key};
			}
			elsif ($key eq 'status') {
				$status = $params{$key};
			}
			else {
				return undef;
			}
		}
	}
	elsif (@_ == 10) {
		my %params = @_;
		for my $key (keys %params) {
			if ($key eq 'name') {
				$name = $params{$key};
			}
			elsif ($key eq 'password') {
				$password = $params{$key};
			}
			elsif ($key eq 'status') {
				$status = $params{$key};
			}
			elsif ($key eq 'id') {
				$id = $params{$key};
			}
			elsif ($key eq 'source') {
				$source = $params{$key};
				$set_source = TRUE;
			}
			else {
				return undef;
			}
		}
	}
	else {
		return undef;
	}

	# execute f5 api and get xml string
	my $xml_string;
	if ($set_source) {
		$xml_string = `$TRANSFER_CMD -u $name:$password -d id=$id -d status="$status" -d source="$source" $SUBMIT_REPLY_URL?api_key=$api_key`;
	}
	else {
		$xml_string = `$TRANSFER_CMD -u $name:$password -d id=$id -d status="$status" $SUBMIT_REPLY_URL?api_key=$api_key`;
	}
	if (!defined($xml_string) || $xml_string eq '') {
		return undef;
	}

	# convert xml string to HASH struct
	$refData = XMLin($xml_string, ForceArray => 1, KeyAttr => '');
	if ($refData eq '') {
		return undef;
	}
	return $refData;
}

1; #terninate this package with 1
