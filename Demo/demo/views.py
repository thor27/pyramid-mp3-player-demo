from pyramid.view import view_config

@view_config(route_name='home', 
             request_method='GET',
             renderer='templates/mytemplate.pt')
def my_view(request):
    return {'project':'Demo'}
