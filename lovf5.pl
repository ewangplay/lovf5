#!/usr/bin/perl -w

# include system module
use strict;
use Gtk2 -init;
use Gtk2::GladeXML;
use FindBin qw($Bin);
use lib "$Bin/lib";

# include user-defined module
use EventHandler;
use ViewManager;
use Account;
use SessionManager;
use Follow5API;
use TrayManager;
use Configure;
use AccelManager;
use WindowManager;
use Common;

# define variant
my $app;
my $f5api;
my $account;
my $session;
my $view;
my $handler;
my $tray;
my $accel;
my $window;

# load UI based glade xml format
$app = Gtk2::GladeXML->new(get_prefix_dir() . '/glade/lovf5.glade');

# create the follow5 api instance
$f5api = new Follow5API($API_KEY);

# create the tray icon instance
$tray = new TrayManager($app);

# create account instance
$account = new Account;

# create session manager instance
$session = new SessionManager($app, $f5api, $account);

# create view manager instance
$view = new ViewManager($app, $f5api, $account);

# create accelerator instance
$accel = new AccelManager($app, $view);

# create the main window manager
$window = new WindowManager($app, $view);

# create event handler instance
$handler = new EventHandler($app, $f5api, $account, $view);

# connect all the sinal to the event handler instance
$app->signal_autoconnect_from_package($handler);

#initialize configure
initialize_config();

# login
$session->login;

# main
if ($login_success) {
        # install accelerator
	$accel->install;

	# init the tray icon
	$tray->init;

	# init the status view
	$view->init;

	# init the window
	$window->init;

	# show window
	$window->show;

	# main loop
	Gtk2->main;
}

