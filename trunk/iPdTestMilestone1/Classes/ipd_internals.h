/*
 *  ipd_internals.h
 *  iPdTestMilestone1
 *
 *  Created by Niv on 10-02-04.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include "m_pd.h"
#include <objc/runtime.h>	//to interface with objective c

static t_class *ipdinlet_class;
static t_class *test_class;

void register_inlet_obj();