package Account;

use strict;

# construct
sub new {
	my $class = shift;
	my $this = {};
	clear($this);
	bless $this, $class;
	return $this;
}

sub clear {
	my $this = shift;
	$this->{'id'} = '';
	$this->{'name'} = '';
	$this->{'password'} = '';
	$this->{'location'} = '';
	$this->{'description'} = '';
	$this->{'profile_image_url'} = '';
	$this->{'url'} = '';
	$this->{'sex'} = '';
	$this->{'birthdy'} = '';
	$this->{'mobile'} = '';
	$this->{'qq'} = '';
	$this->{'msn'} = '';
	$this->{'email'} = '';
	$this->{'created_at'} = '';
	$this->{'favourites_count'} = 0;
	$this->{'followers_count'} = 0;
	$this->{'following_count'} = 0;
	$this->{'friends_count'} = 0;
	$this->{'statuses_count'} = 0;
}

sub id {
	my $this = shift;
	$this->{'id'} = shift if (@_ != 0);
	return $this->{'id'};
}

sub name {
	my $this = shift;
	$this->{'name'} = shift if (@_ != 0);
	return $this->{'name'};
}

sub password {
	my $this = shift;
	$this->{'password'} = shift if (@_ != 0);
	return $this->{'password'};
}

sub location {
	my $this = shift;
	$this->{'location'} = shift if (@_ != 0);
	return $this->{'location'};
}

sub description {
	my $this = shift;
	$this->{'description'} = shift if (@_ != 0);
	return $this->{'description'};
}

sub profile_image_url {
	my $this = shift;
	$this->{'profile_image_url'} = shift if (@_ != 0);
	return $this->{'profile_image_url'};
}

sub url {
	my $this = shift;
	$this->{'url'} = shift if (@_ != 0);
	return $this->{'url'};
}

sub sex {
	my $this = shift;
	$this->{'sex'} = shift if (@_ != 0);
	return $this->{'sex'};
}

sub birthday {
	my $this = shift;
	$this->{'birthday'} = shift if (@_ != 0);
	return $this->{'birthday'};
}

sub mobile {
	my $this = shift;
	$this->{'mobile'} = shift if (@_ != 0);
	return $this->{'mobile'};
}

sub qq {
	my $this = shift;
	$this->{'qq'} = shift if (@_ != 0);
	return $this->{'qq'};
}

sub msn {
	my $this = shift;
	$this->{'msn'} = shift if (@_ != 0);
	return $this->{'msn'};
}

sub email {
	my $this = shift;
	$this->{'email'} = shift if (@_ != 0);
	return $this->{'email'};
}

sub created_at {
	my $this = shift;
	$this->{'created_at'} = shift if (@_ != 0);
	return $this->{'created_at'};
}

sub favourites_count {
	my $this = shift;
	$this->{'favourites_count'} = shift if (@_ != 0);
	return $this->{'favourites_count'};
}

sub followers_count {
	my $this = shift;
	$this->{'followers_count'} = shift if (@_ != 0);
	return $this->{'followers_count'};
}

sub following_count {
	my $this = shift;
	$this->{'following_count'} = shift if (@_ != 0);
	return $this->{'following_count'};
}

sub friends_count {
	my $this = shift;
	$this->{'friends_count'} = shift if (@_ != 0);
	return $this->{'friends_count'};
}

sub statuses_count {
	my $this = shift;
	$this->{'statuses_count'} = shift if (@_ != 0);
	return $this->{'statuses_count'};
}

1; #terminate this package with 1
