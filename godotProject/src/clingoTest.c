#include <gdnative_api_struct.gen.h>

#include <clingo.h>

#include<stdio.h>
#include<stdlib.h>
#include <string.h>

const godot_gdnative_core_api_struct *api = NULL;
const godot_gdnative_ext_nativescript_api_struct *nativescript_api = NULL;


void *simple_constructor(godot_object *p_instance, void *p_method_data);
void simple_destructor(godot_object *p_instance, void *p_method_data, void *p_user_data);
godot_variant simple_get_data(godot_object *p_instance, void *p_method_data, void *p_user_data, int p_num_args, godot_variant **p_args);

const char* solve(clingo_control_t *ctl, clingo_solve_result_bitset_t *result);
const char* simple_godot_main();



void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options *p_options) {
    api = p_options->api_struct;

    // Now find our extensions.
    for (int i = 0; i < api->num_extensions; i++) {
        switch (api->extensions[i]->type) {
            case GDNATIVE_EXT_NATIVESCRIPT: {
                nativescript_api = (godot_gdnative_ext_nativescript_api_struct *)api->extensions[i];
            }; break;
            default: break;
        }
    }
}


void GDN_EXPORT godot_gdnative_terminate(godot_gdnative_terminate_options *p_options) {
    api = NULL;
    nativescript_api = NULL;
}


void GDN_EXPORT godot_nativescript_init(void *p_handle) {
    godot_instance_create_func create = { NULL, NULL, NULL };
    create.create_func = &simple_constructor;

    godot_instance_destroy_func destroy = { NULL, NULL, NULL };
    destroy.destroy_func = &simple_destructor;

    nativescript_api->godot_nativescript_register_class(p_handle, "Simple", "Reference",
            create, destroy);

    godot_instance_method get_data = { NULL, NULL, NULL };
    get_data.method = &simple_get_data;

    godot_method_attributes attributes = { GODOT_METHOD_RPC_MODE_DISABLED };

    nativescript_api->godot_nativescript_register_method(p_handle, "Simple", "get_data",
            attributes, get_data);
}


typedef struct user_data_struct {
    char data[256];
} user_data_struct;


void *simple_constructor(godot_object *p_instance, void *p_method_data) {
    user_data_struct *user_data = api->godot_alloc(sizeof(user_data_struct));
    strcpy(user_data->data, "World from GDNative!");

    return user_data;
}


void simple_destructor(godot_object *p_instance, void *p_method_data, void *p_user_data) {
    api->godot_free(p_user_data);
}


godot_variant simple_get_data(godot_object *p_instance, void *p_method_data,
        void *p_user_data, int p_num_args, godot_variant **p_args) {

    godot_string data;
    godot_variant ret;
    user_data_struct *user_data = (user_data_struct *)p_user_data;

    api->godot_string_new(&data);
    api->godot_string_parse_utf8(&data, simple_godot_main());
    api->godot_variant_new_string(&ret, &data);
    api->godot_string_destroy(&data);

    return ret;
}



//Clingo
const char* print_model(clingo_model_t const *model) {
  const char* ret = "";
  clingo_symbol_t *atoms = NULL;
  size_t atoms_n;
  clingo_symbol_t const *it, *ie;
  char *str = NULL;
  size_t str_n = 0;

  // determine the number of (shown) symbols in the model
  if (!clingo_model_symbols_size(model, clingo_show_type_shown, &atoms_n)) { goto error; }

  // allocate required memory to hold all the symbols
  if (!(atoms = (clingo_symbol_t*)malloc(sizeof(*atoms) * atoms_n))) {
    clingo_set_error(clingo_error_bad_alloc, "could not allocate memory for atoms");
    goto error;
  }

  // retrieve the symbols in the model
  if (!clingo_model_symbols(model, clingo_show_type_shown, atoms, atoms_n)) { goto error; }

  printf("Model:");

  for (it = atoms, ie = atoms + atoms_n; it != ie; ++it) {
    size_t n;
    char *str_new;

    // determine size of the string representation of the next symbol in the model
    if (!clingo_symbol_to_string_size(*it, &n)) { goto error; }

    if (str_n < n) {
      // allocate required memory to hold the symbol's string
      if (!(str_new = (char*)realloc(str, sizeof(*str) * n))) {
        clingo_set_error(clingo_error_bad_alloc, "could not allocate memory for symbol's string");
        goto error;
      }

      str = str_new;
      str_n = n;
    }

    // retrieve the symbol's string
    if (!clingo_symbol_to_string(*it, str, n)) { goto error; }

    ret = str;
    printf(" %s", str);
  }

  printf("\n");
  goto out;

error:
  ret = "false";

out:
  if (atoms) { free(atoms); }
  if (str)   { free(str); }

  return ret;
}

const char* solve(clingo_control_t *ctl, clingo_solve_result_bitset_t *result) {
  const char* ret = "";
  clingo_solve_handle_t *handle;
  clingo_model_t const *model;

  // get a solve handle
  if (!clingo_control_solve(ctl, clingo_solve_mode_yield, NULL, 0, NULL, NULL, &handle)) { goto error; }
  // loop over all models
  while (true) {
    if (!clingo_solve_handle_resume(handle)) { goto error; }
    if (!clingo_solve_handle_model(handle, &model)) { goto error; }
    // print the model
    if (model)
    { 
	    ret = print_model(model); 
    }
    // stop if there are no more models
    else       { break; }
  }
  // close the solve handle
  if (!clingo_solve_handle_get(handle, result)) { goto error; }

  goto out;

error:
  ret = "false";

out:
  // free the solve handle
  clingo_solve_handle_close(handle);
  return ret;
}



const char* simple_godot_main() {
  char const *error_message;
  int argc = 1;
  char const *argv [argc];
  const char* ret = "";
  clingo_solve_result_bitset_t solve_ret;
  clingo_control_t *ctl = NULL;
  clingo_part_t parts[] = {{ "base", NULL, 0 }};

  // create a control object and pass command line arguments
  if (!clingo_control_new(argv+1, argc-1, NULL, NULL, 20, &ctl) != 0) { goto error; }

  // add a logic program to the base part
  if (!clingo_control_add(ctl, "base", NULL, 0, "a :- not b. b :- not a.")) { goto error; }

  // ground the base part
  if (!clingo_control_ground(ctl, parts, 1, NULL, NULL)) { goto error; }

  // solve
  ret = solve(ctl, &solve_ret);

  goto out;

error:
  if (!(error_message = clingo_error_message())) { error_message = "error"; }

  printf("%s\n", error_message);
  //ret = clingo_error_code();

out:
  if (ctl) { clingo_control_free(ctl); }


  return ret;
}







