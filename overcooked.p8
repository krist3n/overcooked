pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- title: overcooked 2
-- author: kristen wang
-- desc: remake of overcooked 2 in pico-8
-- script: lua

function _init()
	-- frame count
	t=0
	
	-- cardinal directions
	dirx={-1,1,0,0}
	diry={0,0,-1,1}
	
	-- server animation
	serv_sp={96,98,100,102}
	
	-- global table of items
	items={
	}
	
	-- player characters
	pl={
	-- player 1
	{
		sp={1,2},
		x=30,
		y=56,
		flipx=false,
		ctrl=0,
		hold=false,
		holdid=nil,
	},
	-- player 2
	{
		sp={3,4},
		x=90,
		y=56,
		flipx=false,
		ctrl=1,
		hold=false,
		holdid=nil,
	},
	}
end

function _update()
	t+=1 
	cls()
	map()
	upd_items()
	upd_pl()
end

function _draw()
	-- draw items
	for i=1,#items do
		spr(items[i].sp,items[i].x,items[i].y)
	end
	-- draw players
	for i=1,#pl do
		spr(get_fr(pl[i].sp),pl[i].x,pl[i].y,1,1,pl[i].flipx)
	end
	-- draw server animation
	mset_2x2(12,4,get_fr(serv_sp))
end

function upd_pl()
	for i=1,#pl do
		-- pl movement
		for j=0,3 do
			if btn(j,pl[i].ctrl) then
				move_pl(pl[i],dirx[j+1],diry[j+1])
			end
		end
		-- pl item
		if btnp(4,pl[i].ctrl) then
			item_pl(pl[i])
		end
		-- pl dash/throw
		if btnp(5,pl[i].ctrl) then
			dash_throw(pl[i])
		end
	end
end

function item_pl(id)
	-- if holding item and near trash
	-- if holding item and near server
	-- elseif holding item
	-- elseif not holding item
	if id.hold==true and in_range(id.x,id.y,1,5) then
		del_item(id)
	elseif id.hold==true and in_range(id.x,id.y,1,6) then
		-- serve
	elseif id.hold==true then
		drop_item(id,0)
	elseif id.hold==false then
		check_int(id)
	end
end

function in_range(x,y,rnge,flg)
	local tile_x=flr(x/8)
 local tile_y=flr(y/8)
 for dx=-rnge,rnge do
  for dy=-rnge,rnge do
   local check_x=tile_x+dx
   local check_y=tile_y+dy
   local tile=mget(check_x,check_y)
   if fget(tile,flg) then
    return true
   end
  end
 end
 return false
end

function check_int(id)
	-- interact with plate
	if id.hold==false then
		if in_range(id.x,id.y,1,1) then
			init_item(id,"plate",144)
		-- interact with fish
		elseif in_range(id.x,id.y,1,2) then
			init_item(id,"fish",128)
		--interact with rice
		elseif in_range(id.x,id.y,1,3) then
			init_item(id,"rice",129)
		--interact with seaweed
		elseif in_range(id.x,id.y,1,4) then
			init_item(id,"seaweed",130)
		else
			pickup_item(id)
		end
	end
end

function init_item(pl_id,i_type,i_sp)
	local i={
		type=it_type,
		sp=i_sp,
		x=pl_id.x,
		y=pl_id.y-5,
		phold=true,
		pl=pl_id,
	}
	add(items,i)
	
	pl_id.hold=true
	pl_id.holdid=#items
end

function upd_items()
	local buff=5
	-- num of pixels to incr item
	-- height by

	for i=1,#items do
		if items[i].phold then
			local p=items[i].pl
			items[i].x=p.x
			items[i].y=p.y-buff
		end
	end
end

function del_item(id)
	del(items,items[id.holdid])
	
	id.hold=false
	id.holdid=nil
end

function drop_item(id,dx)
	local item=items[id.holdid]
	
	id.hold=false
	id.holdid=nil
	
	item.x+=dx
	item.y+=3
	item.phold=false
	item.p=nil
end

function pickup_item(id)
	for i=1,#items do
		local item=items[i]
  if play_col(id,item.x,item.y) then
			id.hold=true
			id.holdid=i
			
			item.phold=true
			item.pl=id
  end
 end
end
-->8
function move_pl(id,dx,dy)
	local destx,desty=id.x+dx,id.y+dy
	local op
	
	if id==pl[1] then
		op=pl[2]
	elseif id==pl[2] then
		op=pl[1]
	end
	
	if wall_col(destx,desty,2,7,0) or play_col(op,destx,desty) then
		--wall
	else
		id.x+=dx
		id.y+=dy
		if dx<0 then
			id.flipx=true
		elseif dx>0 then
			id.flipx=false
		end
	end
end

function get_fr(ani)
	return ani[flr(t/8)%#ani+1]
end

function wall_col(x,y,rng1,rng2,flg)
	local tile_x1=flr((x+rng1)/8)
 local tile_y1=flr((y+rng1)/8)
 local tile_x2=flr((x+rng2)/8)
 local tile_y2=flr((y+rng2)/8)
 
 if fget(mget(tile_x1,tile_y1),flg) or
   	fget(mget(tile_x2,tile_y1),flg) or
    fget(mget(tile_x1,tile_y2),flg) or
    fget(mget(tile_x2,tile_y2),flg) then
     return true  -- collision detected
 end

	return false
end

function play_col(op,dx,dy)
	local d=(dx-op.x)^2+(dy-op.y)^2
	return d<64
end

function mset_2x2(x,y,sp)
  mset(x,y,sp)
  mset(x+1,y,sp+1)
  mset(x,y+1,sp+16)
  mset(x+1,y+1,sp+17)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000002002000000000000c00c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700002222000020020000cccc0000c00c000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000022d2d20002222000cc1c1c000cccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000222200022d2d2000cccc000cc1c1c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700002222000022220000cccc0000cccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000002222000022220000cccc0000cccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000002222000022220000cccc0000cccc000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99999990010000006660666066600000000066600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99999990000000006660666066600000000066600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99999990000000006660666066600000000066600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99999990000000006660666066600000000066600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99999990000000000000000066600000000066600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99999990000000006066606066600000000066600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99999990850005800000000007777700999999909999999099999990999999908576758000000000000000000000000000000000000000000000000000000000
995599905000005033333330d66666d0900000909000009090000090999599905677775000000000000000000000000000000000000000000000000000000000
965566605000005030000030d77777d0900dd090900700909033b090966566605667765000000000000000000000000000000000000000000000000000000000
965569605500055030333030d66666d0901cd09090677090903b3090988589605566655000000000000000000000000000000000000000000000000000000000
965569608555558033333330ddddddd090cc00909077609090b33090988589608555558000000000000000000000000000000000000000000000000000000000
96466660888888800000000000000000900000909000009090000090966466608888888000000000000000000000000000000000000000000000000000000000
994999900000000033333330ddddddd0999999909999999099999990999499900000000000000000000000000000000000000000000000000000000000000000
00000000888888800000000000000000000000000000000000000000000000008888888000000000000000000000000000000000000000000000000000000000
70000000000000707000000700000070700000777000007070000000000000700000000000000000000000000000000000000000000000000000000000000000
70700007000070707070007770007070707007777700707070700000000070700000000000000000000000000000000000000000000000000000000000000000
70000077700000707000077777000070700000000000007070000007000000700000000000000000000000000000000000000000000000000000000000000000
70700777770070707070000000007070707000070000707070700077700070700000000000000000000000000000000000000000000000000000000000000000
70000000000000707000000700000070700000777000007070000777770000700000000000000000000000000000000000000000000000000000000000000000
70700007000070707070007770007070707007777700707070700000000070700000000000000000000000000000000000000000000000000000000000000000
70000077700000707000077777000070700000000000007070000007000000700000000000000000000000000000000000000000000000000000000000000000
70700777770070707070000000007070707000070000707070700077700070700000000000000000000000000000000000000000000000000000000000000000
70000000000000707000000700000070700000777000007070000777770000700000000000000000000000000000000000000000000000000000000000000000
70700007000070707070007770007070707007777700707070700000000070700000000000000000000000000000000000000000000000000000000000000000
70000077700000707000077777000070700000000000007070000007000000700000000000000000000000000000000000000000000000000000000000000000
70700777770070707070000000007070707000070000707070700077700070700000000000000000000000000000000000000000000000000000000000000000
70000000000000707000000000000070700000000000007070000000000000700000000000000000000000000000000000000000000000000000000000000000
77777777777777707777777777777770777777777777777077777777777777700000000000000000000000000000000000000000000000000000000000000000
77777777777777707777777777777770777777777777777077777777777777700000000000000000000000000000000000000000000000000000000000000000
70000000000000707000000000000070700000000000007070000000000000700000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00d0d00000000000033b333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000d00000007700003b3333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000dd00000767700033333b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cccd00007776760033b3b3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0c1cd0000677777003b3333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00cc0000077777700333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00777700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0678e770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03677730008e8e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03333330088e8e8008080e8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
033333300877778008080e8000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00333300077777700e0e0e0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000101010000000000000100000000814121030509118141000000000000000101010101010141000000000000000001010101010141410000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4442424242424242424242424242424300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4440404050505040404040536061404300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4441414141414141414141417071414300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4441414141414141414141414141414300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4441414141544055405641414141414300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4441414141414141414141414141414300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4441414141414141414141414141414300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4440404040405240405151514040404300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4442424242424242424242424242424300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
