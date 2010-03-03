/*
 *  ipd_internals.c
 *  iPdTestMilestone1
 *
 *  Created by Niv on 10-02-02.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

/* "internal" objects - to interface between application and patches...
 more or less specialized inlets and outlets */

#include "ipd_internals.h"
#include <objc/runtime.h>
#include <string.h>
#include <stdlib.h>
#include <stdio.h>

//test ipd inlet

static int numberoutlets = 0;
static int numberinlets = 0;

static void *inletptr = NULL;
static void *outletptr = NULL;

typedef struct _ipdinlet 
{
	t_object x_obj;
	t_float x_f;
} t_ipdinlet;

void *ipdinlet_new(t_floatarg f)
{
	t_ipdinlet *x = (t_ipdinlet *)pd_new(ipdinlet_class);
	x->x_f = f;
	outlet_new(&x->x_obj, &s_float);
	floatinlet_new(&x->x_obj, &x->x_f);
	printf("Number of inlets: %d\n", numberinlets);
	
	inletptr = (t_ipdinlet *) malloc(sizeof(t_ipdinlet) * numberinlets);
	numberinlets++;
	return (x);
}

void ipdinlet_bang(t_ipdinlet *x)
{
	outlet_float(x->x_obj.ob_outlet, (t_float)(int)(x->x_f));
}

void ipdinlet_float(t_ipdinlet *x, t_float f)
{
	outlet_float(x->x_obj.ob_outlet, (t_float)(int)(x->x_f = f));
}

void ipdinlet_setup(void)
{
	ipdinlet_class = class_new(gensym("ipdinlet"),
						   (t_newmethod)ipdinlet_new,
						   0, sizeof(t_ipdinlet),
						   CLASS_DEFAULT, 0);
	class_addcreator((t_newmethod)ipdinlet_new, gensym("ipdinlet"), A_GIMME, 0);
	
	class_addbang(ipdinlet_class, ipdinlet_bang);
	class_addfloat(ipdinlet_class, ipdinlet_float);
}

//test

typedef struct _test {	
	t_object x_obj;
} t_test;

void *test_new(void)
{
	t_test *x = (t_test *)pd_new(test_class);
	return (void *)x;
}

void test_bang(t_test *x)
{
	post("BANG!");
}

void test_setup(void)
{
	test_class = class_new(gensym("test"),
						   (t_newmethod)test_new,
						   0, sizeof(t_test),
						   CLASS_DEFAULT, 0);
	class_addcreator((t_newmethod)test_new, gensym("test"), A_GIMME, 0);
	
	class_addbang(test_class, test_bang);
}

//so we can talk to the ipd process

void register_inlet_obj(void *listobj) {
//	printf("Number of inlets: %d\nsizeof inlet: %d\n", numberinlets, sizeof(t_ipdinlet));
//	inletptr = listobj;
//	printf("Huh? %d\n", (int)listobj);
//	objc_msgSend(inletptr, sel_getUid("testMsg"));
}

//setup all ipd "internals"
void ipd_internals_setup(void)
{
	
	ipdinlet_setup();
	test_setup();
}