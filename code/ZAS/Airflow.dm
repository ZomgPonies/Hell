/*
Contains helper procs for airflow, handled in /connection_group.
*/


mob/var/tmp/last_airflow_stun = 0
mob/proc/airflow_stun()
	if(stat == 2)
		return 0
	if(last_airflow_stun > world.time - vsc.airflow_stun_cooldown)	return 0

	if(!(status_flags & CANSTUN) && !(status_flags & CANWEAKEN))
		src << "<span class='notice'>You stay upright as the air rushes past you.</span>"
		return 0
	if(!lying)
		src << "<span class='warning'>The sudden rush of air knocks you over!</span>"
	Weaken(5)
	last_airflow_stun = world.time

mob/living/silicon/airflow_stun()
	return

mob/living/carbon/metroid/airflow_stun()
	return

mob/living/carbon/human/airflow_stun()
	if(shoes)
		if(shoes.flags & NOSLIP) return 0
	..()

atom/movable/proc/check_airflow_movable(n)

	if(anchored && !ismob(src)) return 0

	if(!istype(src,/obj/item) && n < vsc.airflow_dense_pressure) return 0

	return 1

mob/check_airflow_movable(n)
	if(n < vsc.airflow_heavy_pressure)
		return 0
	return 1

mob/dead/observer/check_airflow_movable()
	return 0

mob/living/silicon/check_airflow_movable()
	return 0


obj/item/check_airflow_movable(n)
	. = ..()
	switch(w_class)
		if(2)
			if(n < vsc.airflow_lightest_pressure) return 0
		if(3)
			if(n < vsc.airflow_light_pressure) return 0
		if(4,5)
			if(n < vsc.airflow_medium_pressure) return 0

/atom/movable/var/tmp/turf/airflow_dest
/atom/movable/var/tmp/airflow_speed = 0
/atom/movable/var/tmp/airflow_time = 0
/atom/movable/var/tmp/last_airflow = 0

/atom/movable/proc/GotoAirflowDest(n)
	if(!airflow_dest) return
	if(airflow_speed < 0) return
	if(last_airflow > world.time - vsc.airflow_delay) return
	if(airflow_speed)
		airflow_speed = n/max(get_dist(src,airflow_dest),1)
		return
	last_airflow = world.time
	if(airflow_dest == loc)
		step_away(src,loc)
	if(ismob(src))
		if(src:status_flags & GODMODE)
			return
		if(istype(src, /mob/living/carbon/human))
			if(src:buckled)
				return
			if(src:shoes && src:shoes.flags & NOSLIP)
				return
		src << "\red You are sucked away by airflow!"
	var/airflow_falloff = 9 - ul_FalloffAmount(airflow_dest) //It's a fast falloff calc.  Very useful.
	if(airflow_falloff < 1)
		airflow_dest = null
		return
	airflow_speed = min(max(n * (9/airflow_falloff),1),9)
	var
		xo = airflow_dest.x - src.x
		yo = airflow_dest.y - src.y
		od = 0
	airflow_dest = null
	if(!density)
		density = 1
		od = 1
	while(airflow_speed > 0)
		if(airflow_speed <= 0) return
		airflow_speed = min(airflow_speed,15)
		airflow_speed -= vsc.airflow_speed_decay
		if(airflow_speed > 7)
			if(airflow_time++ >= airflow_speed - 7)
				if(od)
					density = 0
				sleep(1 * tick_multiplier)
		else
			if(od)
				density = 0
			sleep(max(1,10-(airflow_speed+3)) * tick_multiplier)
		if(od)
			density = 1
		if ((!( src.airflow_dest ) || src.loc == src.airflow_dest))
			src.airflow_dest = locate(min(max(src.x + xo, 1), world.maxx), min(max(src.y + yo, 1), world.maxy), src.z)
		if ((src.x == 1 || src.x == world.maxx || src.y == 1 || src.y == world.maxy))
			return
		if(!istype(loc, /turf))
			return
		step_towards(src, src.airflow_dest)
		if(ismob(src) && src:client)
			src:client:move_delay = world.time + vsc.airflow_mob_slowdown
	airflow_dest = null
	airflow_speed = 0
	airflow_time = 0
	if(od)
		density = 0


/atom/movable/proc/RepelAirflowDest(n)
	if(!airflow_dest) return
	if(airflow_speed < 0) return
	if(last_airflow > world.time - vsc.airflow_delay) return
	if(airflow_speed)
		airflow_speed = n/max(get_dist(src,airflow_dest),1)
		return
	if(airflow_dest == loc)
		step_away(src,loc)
	if(ismob(src))
		if(src:status_flags & GODMODE)
			return
		if(istype(src, /mob/living/carbon/human))
			if(src:buckled)
				return
			if(src:shoes && src:shoes.flags & NOSLIP)
				return
		src << "\red You are pushed away by airflow!"
		last_airflow = world.time
	var/airflow_falloff = 9 - ul_FalloffAmount(airflow_dest) //It's a fast falloff calc.  Very useful.
	if(airflow_falloff < 1)
		airflow_dest = null
		return
	airflow_speed = min(max(n * (9/airflow_falloff),1),9)
	var
		xo = -(airflow_dest.x - src.x)
		yo = -(airflow_dest.y - src.y)
		od = 0
	airflow_dest = null
	if(!density)
		density = 1
		od = 1
	while(airflow_speed > 0)
		if(airflow_speed <= 0) return
		airflow_speed = min(airflow_speed,15)
		airflow_speed -= vsc.airflow_speed_decay
		if(airflow_speed > 7)
			if(airflow_time++ >= airflow_speed - 7)
				sleep(1 * tick_multiplier)
		else
			sleep(max(1,10-(airflow_speed+3)) * tick_multiplier)
		if ((!( src.airflow_dest ) || src.loc == src.airflow_dest))
			src.airflow_dest = locate(min(max(src.x + xo, 1), world.maxx), min(max(src.y + yo, 1), world.maxy), src.z)
		if ((src.x == 1 || src.x == world.maxx || src.y == 1 || src.y == world.maxy))
			return
		if(!istype(loc, /turf))
			return
		step_towards(src, src.airflow_dest)
		if(ismob(src) && src:client)
			src:client:move_delay = world.time + vsc.airflow_mob_slowdown
	airflow_dest = null
	airflow_speed = 0
	airflow_time = 0
	if(od)
		density = 0

/atom/movable/Bump(atom/A)
	if(airflow_speed > 0 && airflow_dest)
		airflow_hit(A)
	else
		airflow_speed = 0
		airflow_time = 0
		. = ..()

atom/movable/proc/airflow_hit(atom/A)
	airflow_speed = 0
	airflow_dest = null

mob/airflow_hit(atom/A)
	for(var/mob/M in hearers(src))
		M.show_message("\red <B>\The [src] slams into \a [A]!</B>",1,"\red You hear a loud slam!",2)
	playsound(src.loc, "smash.ogg", 25, 1, -1)
	var/weak_amt = istype(A,/obj/item) ? A:w_class : rand(1,5) //Heheheh
	Weaken(weak_amt)
	. = ..()

obj/airflow_hit(atom/A)
	for(var/mob/M in hearers(src))
		M.show_message("\red <B>\The [src] slams into \a [A]!</B>",1,"\red You hear a loud slam!",2)
	playsound(src.loc, "smash.ogg", 25, 1, -1)
	. = ..()

obj/item/airflow_hit(atom/A)
	airflow_speed = 0
	airflow_dest = null

mob/living/carbon/human/airflow_hit(atom/A)
//	for(var/mob/M in hearers(src))
//		M.show_message("\red <B>[src] slams into [A]!</B>",1,"\red You hear a loud slam!",2)
	playsound(src.loc, "punch", 25, 1, -1)
	if (prob(33))
		loc:add_blood(src)
		bloody_body(src)
	var/b_loss = airflow_speed * vsc.airflow_damage

	var/blocked = run_armor_check("head","melee")
	apply_damage(b_loss/3, BRUTE, "head", blocked, 0, "Airflow")

	blocked = run_armor_check("chest","melee")
	apply_damage(b_loss/3, BRUTE, "chest", blocked, 0, "Airflow")

	blocked = run_armor_check("groin","melee")
	apply_damage(b_loss/3, BRUTE, "groin", blocked, 0, "Airflow")

	if(airflow_speed > 10)
		Paralyse(round(airflow_speed * vsc.airflow_stun))
		Stun(paralysis + 3)
	else
		Stun(round(airflow_speed * vsc.airflow_stun/2))
	. = ..()

zone/proc/movables()
	. = list()
	for(var/turf/T in contents)
		for(var/atom/A in T)
			if(istype(A, /obj/effect) || istype(A, /mob/aiEye))
				continue
			. += A

//ULTRALIGHT - only file where this is still used, hence why it's in here
#define UL_I_FALLOFF_SQUARE 0
#define UL_I_FALLOFF_ROUND 1
#define ul_FalloffStyle UL_I_FALLOFF_ROUND // Sets the lighting falloff to be either squared or circular.
var/list/ul_FastRoot = list(0, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 5, 5,
							5, 5, 5, 5, 5, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
							7, 7)

atom/proc/ul_FalloffAmount(var/atom/ref)
	if (ul_FalloffStyle == UL_I_FALLOFF_ROUND)
		var/delta_x = (ref.x - src.x)
		var/delta_y = (ref.y - src.y)

		#ifdef ul_LightingResolution
		if (round((delta_x*delta_x + delta_y*delta_y)*ul_LightingResolutionSqrt,1) > ul_FastRoot.len)
			for(var/i = ul_FastRoot.len, i <= round(delta_x*delta_x+delta_y*delta_y*ul_LightingResolutionSqrt,1), i++)
				ul_FastRoot += round(sqrt(i))
		return ul_FastRoot[round((delta_x*delta_x + delta_y*delta_y)*ul_LightingResolutionSqrt, 1) + 1]/ul_LightingResolution

		#else
		if ((delta_x*delta_x + delta_y*delta_y) > ul_FastRoot.len)
			for(var/i = ul_FastRoot.len, i <= delta_x*delta_x+delta_y*delta_y, i++)
				ul_FastRoot += round(sqrt(i))
		return ul_FastRoot[delta_x*delta_x + delta_y*delta_y + 1]

		#endif

	else if (ul_FalloffStyle == UL_I_FALLOFF_SQUARE)
		return get_dist(src, ref)

	return 0