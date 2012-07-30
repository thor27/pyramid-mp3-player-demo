<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>jQuery UI Draggable + Sortable</title>
    <link rel="stylesheet" href="/static/jquery.ui.all.css">
    <script src="/static/jquery-1.7.2.js"></script>
    <script src="/static/jquery.ui.core.js"></script>
    <script src="/static/jquery.ui.widget.js"></script>
    <script src="/static/jquery.ui.mouse.js"></script>
    <script src="/static/jquery.ui.draggable.js"></script>
    <script src="/static/jquery.ui.sortable.js"></script>
    <style>
        .demo div { 
            margin: 20px; 
            width: 180px; 
            float: left;
        }
        .demo ul { 
            list-style-type: none; 
            padding: 10px; 
            min-width: 175px; 
            background-color: #F0F0FF; 
            height: 300px;
            overflow-y: scroll;
        }
        .demo li { 
            margin: 5px; 
            padding: 5px; 
            width: 150px; 
        }
        .remove { 
            color: #777777!important;
            float: right;
            font-size: 8px;
            text-align: right;
        }
        #draggable li a{
            display: none!important;
        }
        .playing {
            background-color: Blue;
        }
    </style>
    <script>
        var POSICAO=0;
        var ID=${playlist.id};
        
        function tocar(){
            $('#sortable').find('li').removeClass('playing');
            var audio = $('#sortable').find('li').eq(POSICAO);
            audio.addClass('playing');
            $('#playingnow').html(audio.attr('audio'));
            if (audio.attr("audio") != null ) {
                $('#player').attr("src",'/files/'+audio.attr("audio"));
                document.getElementById('player').play();
            }
        }
        
        $(function() {
            $( "#sortable" ).sortable({
                revert: true,
                update: function(event, ui) { 
                    list = []
                    val = 0;
                    $(this).find('li').each(function(){
                         list.push({ 
                            'position': val,
                            'title':$(this).attr('audio'),
                            'url':$(this).attr('audio'),
                            'playlist_id':ID
                         });
                         val+=1;
                    });
                    console.debug(list);
                     $.ajax('/audio', {
                        type: 'DELETE',
                        success: function (data, status, xhr) {
                            $.ajax('/audio', {
                                type: 'POST',
                                data: list[0],
                                
                            });
                        }
                    });
                }
                
            });
            $( "#draggable li" ).draggable({
                connectToSortable: "#sortable",
                helper: "clone",
                revert: "invalid"
            });
            $( "ul, li" ).disableSelection();
            $(".demo").delegate(".remove","click", function(){
                $(this).parent().remove();
            });
            
            $("#player").bind('ended', function(){
                $('#playingnow').html("");
                POSICAO+=1;
                tocar();
            });
            $("#iniciar").click(function(){
                POSICAO=0;
                tocar();
            });
        });
    </script>
</head>
    <body>
        <h1>${playlist.title}</h1>
        <h2>${playlist.description}</h2>
        
        <div class="demo">
            <div>
                Músicas
                <ul id="draggable">
                      % for music in musics:
                        <li class="ui-state-default" audio="${music}">${music}<a href="#" class="remove">X</a></li>
                      % endfor
                </ul>
            </div>

            <div>
                Lista de reprodução
                <a href="#" id="iniciar">Iniciar</a>
                <ul id="sortable">
                    
                </ul>
            </div>

            <div>
                Player
                <div id="playingnow"></div>
                <audio controls="controls" id="player"></audio>
            </div>
            
        </div><!-- End demo -->
    </body>
</html>


