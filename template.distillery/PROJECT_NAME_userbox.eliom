(* Copyright Vincent Balat *)
(* This file was generated by Eliom-base-app.
   Feel free to use it, modify it, and redistribute it as you wish. *)


{shared{
open Eliom_content.Html5
open Eliom_content.Html5.F
}}


let connected_user_box user =
  lwt username = %%%MODULE_NAME%%%_view.username user in
  Lwt.return (div ~a:[a_id "incus-user-box"] [
    %%%MODULE_NAME%%%_view.avatar user;
    username;
    %%%MODULE_NAME%%%_view.disconnect_button ();
  ])


{client{
  let display_error cont msg f =
    let msg = To_dom.of_p (p ~a:[a_class ["eba_error"]] [pcdata msg]) in
    ignore (f ());
    Dom.appendChild cont msg;
    ignore
      (lwt () = Lwt_js.sleep 2. in Dom.removeChild cont msg; Lwt.return ())
}}


let connection_box () =
  let id = "eba_login_signup_box" in
  if Eliom_reference.Volatile.get %%%MODULE_NAME%%%_err.activation_key_created
  then
    Lwt.return
      (D.div ~a:[a_id id]
         [p [pcdata "An email has been sent to this address.";
             br();
             pcdata "Click on the link it contains to log in."]])
  else
    let set = {Ow_active_set.t'{
      Ow_active_set.to_server_set
        (Ow_active_set.set ~at_least_one:true ())
    }} in
    let button1 = D.h2 [pcdata "Login"] in
    let form1 = %%%MODULE_NAME%%%_view.connect_form () in
    let o1,_ =
      Ow_button.button_alert
        ~set
        ~pressed:true
        button1
        form1
    in
    let button2 = D.h2 [pcdata "Lost password"] in
    let form2 = %%%MODULE_NAME%%%_view.forgot_password_form () in
    let o2,_ =
      Ow_button.button_alert
        ~set:set
        button2
        form2
    in
    let button3 = D.h2 [pcdata "Preregister"] in
    let form3 =
      %%%MODULE_NAME%%%_view.preregister_form
        "Enter your e-mail address to get informed when the site opens \
         and be one of the first users"
    in
    let o3,_ =
      Ow_button.button_alert
        ~set
        button3
        form3
    in
    let button4 = D.h2 [pcdata "Register"] in
    let form4 = %%%MODULE_NAME%%%_view.sign_up_form () in
    let o4,_ =
        Ow_button.button_alert
          ~set
          button4
          form4
    in
    (* function to press the corresponding button and display
     * the flash message error.
     * [d] is currently an server value, so we need to use % *)
    let press but cont msg =
      ignore {unit{
        display_error (To_dom.of_element %cont) %msg
          (fun () -> (Ow_button.to_button_alert %but)##press())
        }};
      Lwt.return ()
    in
    let display_error o34 d =
      (* Function to display flash message error *)
      let wrong_password =
        Eliom_reference.Volatile.get %%%MODULE_NAME%%%_err.wrong_password
      in
      let user_already_exists =
        Eliom_reference.Volatile.get %%%MODULE_NAME%%%_err.user_already_exists
      in
      let user_does_not_exist =
        Eliom_reference.Volatile.get %%%MODULE_NAME%%%_err.user_does_not_exist
      in
      let user_already_preregistered =
        Eliom_reference.Volatile.get
          %%%MODULE_NAME%%%_err.user_already_preregistered
      in
      let activation_key_outdated =
        Eliom_reference.Volatile.get
          %%%MODULE_NAME%%%_err.activation_key_outdated
      in

      if wrong_password
      then press o1 d "Wrong password"
      else if activation_key_outdated
      then press o2 d "Invalid activation key, ask for a new one."
      else if user_already_exists
      then press o34 d "E-mail already exists"
      else if user_does_not_exist
      then press o2 d "User does not exist"
      else if user_already_preregistered
      then press o3 d "E-mail already preregistered"
      else Lwt.return ()
    in

    (* Here we will return the div correponding to the current
     * website state, and also a function to handle specific
     * flash messages *)
    let d, handle_rmsg =
    (* If the registration is not open (pre-registration only): *)
        (* (D.div ~a:[a_id id] *)
        (*    [button1; button3; button2; form1; form3; form2]), *)
        (* display_error o3 *)
    (* otherwise *)
      (D.div ~a:[a_id id]
         [button1; button2; button4; form1; form2; form4]),
      display_error o4
    in
    lwt () = handle_rmsg d in
    Lwt.return d

let userbox user =
  match user with
    | Some user -> connected_user_box user
    | None -> connection_box ()
