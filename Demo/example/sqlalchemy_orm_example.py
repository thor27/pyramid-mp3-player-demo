"""
SQLAlchemy ORM Example
======================

To run this example, first install pyramid_restler and SQLAlchemy (perhaps
in a virtualenv). Once that's done, cd into the examples/ directory, run
`python sqlalchemy_orm_example.py`, and open http://localhost:5000/ in
your browser. From there, you can play around with CRUD from a very simple
UI.

Note: a temporary SQLite database is created in the current working
directory every time this module is run; it is removed automatically when
the server is shut down normally (e.g., via Ctrl-C). The `DB_NAME` global
specifies the name of this database.

"""
from pyramid.config import Configurator

from pyramid_restler.model import SQLAlchemyORMContext

from sqlalchemy.engine import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from sqlalchemy.schema import Column
from sqlalchemy.types import Integer, String
from sqlalchemy import ForeignKey 
import os
Base = declarative_base()

FOLDER='/home/thor27/audios'

class MyPlaylist(Base):

    __tablename__ = 'my_playlist'

    id = Column(Integer, primary_key=True)
    title = Column(String(100), nullable=False)
    description = Column(String)

class Audio(Base):
    __tablename__ = 'audio'
    
    id = Column(Integer, primary_key=True)
    position = Column(Integer)
    title = Column(String(100), nullable=False)
    url = Column(String(100), nullable=False)
    playlist_id = Column(Integer, ForeignKey(MyPlaylist.id), nullable=False),

class MyPlaylistContextFactory(SQLAlchemyORMContext):

    entity = MyPlaylist

    def session_factory(self):
        return Session()

class AudioContextFactory(SQLAlchemyORMContext):

    entity = Audio

    def session_factory(self):
        return Session()
        
def root_view(context, request):
    playlists = Session().query(MyPlaylist).all()
    return dict(playlists=playlists, Playlist=MyPlaylist)

def radio_view(context, request, *args, **kwargs):
    musics = os.listdir(FOLDER)
    
    playlist = Session().query(MyPlaylist).get(context.radio_id)
    return dict(playlist=playlist, musics=musics)

def main(global_config, **settings):
    db_path = settings['db_path']
    print('Temporary SQLite database created at {0}.'.format(db_path))

    global Session
    engine = create_engine('sqlite:///{0}'.format(db_path))
    Session = sessionmaker(bind=engine)
    create_and_populate_database(engine)

    config = Configurator(settings=settings)
    config.add_route('root', '/')
    config.add_route('radio', '/radio/{radio_id}')
    config.add_static_view(name='static', path='/home/thor27/projetos/pyramid-demo/Demo/static')
    config.add_static_view(name='files', path='/home/thor27/audios')
    config.add_view(route_name='root', view=root_view, renderer='example.mako')
    config.add_view(route_name='radio', view=radio_view, renderer='radio.mako')
    config.add_restful_routes('playlist', MyPlaylistContextFactory)
    config.add_restful_routes('audio', AudioContextFactory)
    config.enable_POST_tunneling()
    return config.make_wsgi_app()


def create_and_populate_database(engine):
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    engine.execute(
        MyPlaylist.__table__.insert(),
        dict(title='One', description='First'),
        dict(title='Two', description='Second'),
        dict(title='Three', description='Third'),
    )
