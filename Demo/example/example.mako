<html>
  <head>
    <title>pyramid_restler Example</title>
    <style>
      table {
        border-collapse: collapse;
      }
      table, th, td {
        border: 1px solid black;
      }
      form {
        margin: 0;
        padding: 0;
      }
    </style>
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js"></script>
    <script src="http://ajax.microsoft.com/ajax/jquery.templates/beta1/jquery.tmpl.min.js"></script>
  </head>

  <body>
    <h2>Playlists</h2>

    <table id="playlists">
      <tr>
        <th>ID</th>
        <th>Title</th>
        <th>Description</th>
        <th>GET</th>
        <th>EDITAR</th>
        <th>DELETE</th>
     </tr>
      % for playlist in playlists:
        ${self.playlist(playlist)}
      % endfor
    </table>

    <p>
      <a href="/playlist.json">GET collection as JSON</a>
    </p>

    <h2>Create Playlist</h2>

    <form id="create-member-form" method="POST" action="/playlist">
      Title: <input type="text" name="title" /><br />
      Description: <input type="text" name="description" /><br />
      <input type="submit" value="POST /playlist" />
    </form>

    <h2>Edit Playlist</h2>

    <form id="edit-member-form" method="POST" action="#">
      <input type="text" name="id" /> ID of Playlist to edit<br />
      <input type="text" name="title" /> Title<br />
      <input type="text" name="description" /> Description<br />
      <input type="hidden" name="$method" value="PUT" />
      <input type="submit" value="PUT /playlist/{ID}" />
    </form>

    <script id="playlist-template" type="text/x-jquery-tmpl">
      ${self.playlist(Playlist(id='${id}', title='${title}', description='${description}'))}
    </script>

    <script>//<![CDATA[
      $(document).ready(function () {

        function onCreate (location) {
          $.ajax(location, {
            dataType: 'json',
            success: function (data) {
              var playlist = data.results;
              var row = $('#playlist-template').tmpl(playlist).appendTo('#playlists');
              registerDeleteFormHandlers('#playlist-' + playlist.id);
            }
          });
        }

        function onUpdate (id, fields) {
          var tr = $('#playlist-' + id);
          $.each(fields, function (i, item) {
            var name = item.name;
            if (name === 'title' || name === 'description') {
              tr.find('td.playlist-field-' + name).html(item.value);
            }
          });
        }

        $('form#create-member-form').submit(function (e) {
          e.preventDefault();
          $.ajax(this.action, {
            type: 'POST',
            data: $(this).serialize(),
            context: this,
            success: function (data, status, xhr) {
              onCreate(xhr.getResponseHeader('Location'));
            }
          });
        });

        $('form#edit-member-form').submit(function (e) {
          e.preventDefault();
          var id = $(this).find('input[name=id]').first().val();
          var action = '/playlist/' + id;
          var fields = $(this).serializeArray();
          $.ajax(action, {
            type: this.method,
            data: $(this).serialize(),
            success: function (data, status, xhr) {
              if (xhr.status == 204) {
                onUpdate(id, fields);
              } else if (xhr.status == 201) {
                onCreate(xhr.getResponseHeader('Location'));
              }
            }
          });
        });

        function registerDeleteFormHandlers (selector) {
          selector = selector || 'form.delete-member-form';
          $(selector).submit(function (e) {
            e.preventDefault();
            $.ajax(this.action, {
              type: this.method,
              data: $(this).serialize(),
              context: this,
              success: function () {
                $(this).closest('tr').remove();
              }
            });
          });
        }

        registerDeleteFormHandlers();
      });
    //]]</script>
  </body>
</html>


<%def name="playlist(playlist)">
  <tr id="playlist-${playlist.id}">
    <td class="playlist-field-id">${playlist.id}</td>
    <td class="playlist-field-title">${playlist.title}</td>
    <td class="playlist-field-description">${playlist.description}</td>
    <td><a class="playlist-get-link" href="/playlist/${playlist.id}">GET /playlist/${playlist.id}</a></td>
    <td><a class="playlist-get-link" href="/radio/${playlist.id}">ABRIR</a></td>
    <td>
      <form class="delete-member-form" method="POST" action="/playlist/${playlist.id}">
        <input type="hidden" name="$method" value="DELETE" />
        <input type="submit" value="DELETE /playlist/${playlist.id}" />
      </form>
    </td>
  </tr>
</%def>
