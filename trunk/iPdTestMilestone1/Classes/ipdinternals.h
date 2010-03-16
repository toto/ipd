/*
 *  ipdinternals.h
 *  iPdTestMilestone1
 *
 *  Created by Niv on 10-03-14.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "m_pd.h"

static t_class *ipdoutlet_class;

typedef struct _ipdoutlet
{
	t_object x_obj;
	t_object *o_owner;
	char *selector[MAXPDSTRING];
} t_ipdoutlet;