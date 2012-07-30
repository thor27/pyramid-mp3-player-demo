from pyramid.config import Configurator

class HttpMethodOverrideMiddleware(object):
    '''WSGI middleware for overriding HTTP Request Method for RESTful support
    '''
    def __init__(self, application):
        self.application = application
 
 
    def __call__(self, environ, start_response):
        if 'POST' == environ['REQUEST_METHOD']:
            override_method = ''
 
            # First check the "_method" form parameter
            if 'form-urlencoded' in environ['CONTENT_TYPE']:
                from webob import Request
                request = Request(environ)
                override_method = request.str_POST.get('_method', '').upper()
 
            # If not found, then look for "X-HTTP-Method-Override" header
            if not override_method:
                override_method = environ.get('HTTP_X_HTTP_METHOD_OVERRIDE', '').upper()
 
            if override_method in ('PUT', 'DELETE', 'OPTIONS', 'PATCH'):
                # Save the original HTTP method
                environ['http_method_override.original_method'] = environ['REQUEST_METHOD']
                # Override HTTP method
                environ['REQUEST_METHOD'] = override_method
 
        return self.application(environ, start_response)

def main(global_config, **settings):
    """ This function returns a Pyramid WSGI application.
    """
    config = Configurator(settings=settings)
    config.add_static_view('static', 'static', cache_max_age=3600)
    config.add_route('home', '/')
    config.scan()
    return HttpMethodOverrideMiddleware(config.make_wsgi_app())
