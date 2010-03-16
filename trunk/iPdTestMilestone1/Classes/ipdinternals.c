/*
 *  ipdinternals.c
 *  iPdTestMilestone1
 *
 *  Created by Niv on 10-03-14.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "ipdinternals.h"
#include <objc/runtime.h>

/* 03/13/2010 HACKED IPD OUTLET -----------------------------*/

t_ipdoutlet *ipdoutlet_new(t_object *owner)
{
	t_ipdoutlet *x = (t_ipdoutlet *)pd_new(ipdoutlet_class);
	x->o_owner = owner;
	//strcpy(*x->selector, "test");
	return (x);
}

static void ipdoutlet_bang(t_ipdoutlet *x) 
{
	objc_msgSend(ipd_ptr, sel_getUid("bangOut"), NULL);
}

void ipdoutlet_setup(void)
{
	ipdoutlet_class = class_new(gensym("ipdoutlet"), 
								(t_newmethod)ipdoutlet_new, 0, 
								sizeof(t_ipdoutlet), 0, A_GIMME, 0);
	class_addbang(ipdoutlet_class, ipdoutlet_bang);
}

void ipdinternals_setup(void)
{
	ipdoutlet_setup();
}