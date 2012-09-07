package Mojolicious::Plugin::JSONP;
use Mojo::Base 'Mojolicious::Plugin';
use Data::Dumper;

our $VERSION = '0.01';

sub register {
  my ($self, $app, $conf) = @_;

  $app->helper(
    render_jsonp => sub {
      my ($self, $callback, $ref) = @_;

      # $callback is optional
      $ref = $callback, undef $callback if !defined $ref;

      # use default from plugin conf if callback not specified
      #$callback //= $self->param($conf->{callback});
      $callback = $self->param($conf->{callback}) if !$callback;

      return $callback
        ?   $self->render(text => $callback . '('
          . $self->render(json => $ref, partial => 1) . ')')
        : $self->render_json($ref);
    }
  );
}

1;
__END__

=head1 NAME

Mojolicious::Plugin::JSONP - Render JSONP with transparent fallback to JSON

=head1 SYNOPSIS

  # Mojolicious
  $self->plugin(JSONP => (callback => 'callback_function'));

  # Mojolicious::Lite
  plugin JSONP => (callback => 'callback_function');

  get '/' => sub {
    shift->render_jsonp({one => 'two'});
  };

=head1 DESCRIPTION

L<Mojolicious::Plugin::JSONP> is a helper for rendering JSONP 
with a transparent fallback to JSON if a callback parameter is not specified.

The render_jsonp helper will render a Perl reference as JSON, wrapped in a supplied callback.
If a callback is not supplied, only the JSON structure will be returned.

=head2 Explanation

Given the following configuration:

    plugin JSON => (callback => 'callback_function');

And the following action:

    get '/' {
      shift->render_jsonp({one => 'two'})
    };

And this client (browser) request:

    http://domain.com/?callback_function=my_function

The following will be returned:

    my_function({"one":"two"});

If the client request does not specify the expected callback function:

  http://domain.com/  # No parameters specified

Only the JSON will be returned:

{"one":"two"}

Optionally, you can specify a callback parameter in the render_jsonp helper:

    get '/' => sub {
      shift->render_jsonp(callback_function => {one => "two"});
    };

This has the same effect as specifying the callback function in the 
plugin configuration, and will override the plugin configuration.

=head1 METHODS

L<Mojolicious::Plugin::JSONP> inherits all methods from
L<Mojolicious::Plugin> and implements the following new ones.

=head2 C<register>

  $plugin->register(Mojolicious->new);

Register plugin in L<Mojolicious> application.

=head1 SEE ALSO

L<Mojolicious>, L<Mojolicious::Guides>, L<http://mojolicio.us>.

=cut
