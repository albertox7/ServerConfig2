register_command('herotransform', 

    array(
        'description': 'Transform into a powered up hero',
        'usage': '',
        'permission': 'powers.herotransform',
        'noPermMsg': 'Sorry you don\'t have permission to use this command.',
    
        'executor': closure(@alias, @sender, @args) {
       
            if(array_size(@args) != 1){
                include('/home/minecraft/server/plugins/CommandHelper/includes/getHeroClass.ms')
                @class = _getheroclass(@sender)
                @contents = read('/home/minecraft/server/plugins/CommandHelper/LocalPackages/commands/chars/'.@class.'.yml')
                @hero = yml_decode(@contents)
                @transformations = @hero['transformations']
                msg(color('RED').'The available transformations you have are:')
                foreach(@transformation in @transformations){
                    try{
                        @contents = read('/home/minecraft/server/plugins/CommandHelper/LocalPackages/commands/chars/'.@transformation.'.yml')
                        @hero = yml_decode(@contents)
                        runas('~console','/tellraw '.@sender.' {"text":"'.@hero['costumes'][0]['name'].'","color":"gold","clickEvent":{"action":"run_command","value":"/herotransform '.@transformation.'"},"hoverEvent":{"action":"show_text","value":"'.@transformation.'"}}')
                    }catch(IOException @e){}
                }
                msg(color('RED').'Click a character to transform.')
                return(false)
            }
 
            @idToBe = @args[0]
            include('/home/minecraft/server/plugins/CommandHelper/includes/getHeroClass.ms')
            @player = player()
            @class = _getheroclass(@player)

            @contents = read('/home/minecraft/server/plugins/CommandHelper/LocalPackages/commands/chars/'.@class.'.yml')
            @oldHero = yml_decode(@contents)
            if(!array_index_exists(@oldHero,'transformations')){
                msg(color('RED').'Sorry, your character doesn\'t have any available transformations')
                die()
            }

            @plrs = all_players()
            foreach(@plr in @plrs){
                @class = _getheroclass(@plr)
                if(@class == @idToBe){
                    @contents = read('/home/minecraft/server/plugins/CommandHelper/LocalPackages/commands/chars/'.@class.'.yml')
                    @hero = yml_decode(@contents)
                    msg(color('RED').'Sorry, but '.@plr.' is already '.@hero['costumes'][0]['name'])
                    die()
                }
            }

            @transformations = @oldHero['transformations']
            @goAhead = false

            foreach(@transformation in @transformations){
                if(@transformation == @idToBe){
                    @goAhead = true
                }
            }

            if(@goAhead){
                tmsg(@player,color('GREEN').color('BOLD').'Transforming!')
                @contents = read('/home/minecraft/server/plugins/CommandHelper/LocalPackages/commands/chars/'.@idToBe.'.yml')
                @newHero = yml_decode(@contents)
        
                #runas('~console','/pex user '.@player.' group set '.@idToBe)
                queue_push(closure(runas('~console','/pex group #'.@idToBe.' delete')))
                queue_push(closure(runas('~console','/pex group #'.@idToBe.' create')))
                queue_push(closure(runas('~console','/pex user '.@player.' group set #'.@idToBe)))
                queue_push(closure(runas('~console','/pex group #'.@idToBe.' parents set #commonherotraits')))
                queue_push(closure(runas('~console','/pex group #'.@idToBe.' suffix '.@newHero['costumes'][0]['color'])))
                @niceName = replace(@newHero['costumes'][0]['name'],'§','&')
                queue_push(closure(runas('~console','/pex group #'.@idToBe.' prefix "'.@niceName.'"')))
                foreach(@worldName: @worldPerms in @newHero['permissions']){
                    foreach(@perm in @worldPerms){
                        queue_push(closure(runas('~console','/pex group #'.@idToBe.' add '.@perm.' '.@worldName)))
                    }
                }
                queue_push(closure(runas('~console',"/fly ".@player." off")))
                queue_push(closure(runas('~console',"/gamemode survival ".@player)))
                queue_push(closure(runas('~console',"/minecraft:clear ".@player)))
                queue_push(closure(set_peffect(@player, 14, 1, 9999, true, false)))
                queue_push(closure(runas('~console',"/god ".@player." off")))
                queue_push(closure(runas('~console',"/tptoggle ".@player." on")))
                
                if(@newHero['trail'] != ''){
                    queue_push(closure(sudo("/trailsid ".@newHero['trail'])))
                }else{
                    queue_push(closure(sudo("/trailsid none")))
                }
                set_timeout(1000,closure(
                    queue_push(closure(run_cmd('/fixskin')))
                ))
                if(has_permission(@player,'essentials.fly')){
                    queue_push(closure(run_cmd('/fly on')))
                }
                queue_push(closure(runas('~console',"/minecraft:effect ".@player." clear")))
                if(has_permission(@player,'ch.alias.buff')){
                    queue_push(closure(runas(@player,'/buff')))
                }

                
                if(array_index_exists(@newHero,'silentTransformMessage') && @newHero['silentTransformMessage'] == true){
                    queue_push(closure(msg(color('RED').'You changed your name to '.@newHero['costumes'][0]['name'])))
                }else{
                    queue_push(closure(sudo('/powers')))
                    queue_push(closure(broadcast(color('BLUE').@player.color('GRAY').' has performed a hero transformation from '.@oldHero['costumes'][0]['name'].color('GRAY').' to '.@newHero['costumes'][0]['name'].color('GRAY').' !')))
                }

            }else{
                msg(color('RED').'Sorry, the available transformations you have are:')
                foreach(@transformation in @transformations){
                    try{
                        @contents = read('/home/minecraft/server/plugins/CommandHelper/LocalPackages/commands/chars/'.@transformation.'.yml')
                        @hero = yml_decode(@contents)
                        queue_push(closure(runas('~console','/tellraw '.@sender.' {"text":"'.@hero['costumes'][0]['name'].'","color":"gold","clickEvent":{"action":"run_command","value":"/herotransform '.@transformation.'"},"hoverEvent":{"action":"show_text","value":"'.@transformation.'"}}')))
                    }catch(IOException @e){}
                }
                msg(color('RED').'Click a character to transform.')
            }

        }
    )
)
