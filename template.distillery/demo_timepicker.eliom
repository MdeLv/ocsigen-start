[%%shared
(* This file was generated by Ocsigen Start.
   Feel free to use it, modify it, and redistribute it as you wish. *)

open Eliom_content.Html.D]

[%%client open Js_of_ocaml_lwt]

(* Timepicker demo *)

(* Service for this demo *)
let%server service =
  Eliom_service.create
    ~path:(Eliom_service.Path ["demo-timepicker"])
    ~meth:(Eliom_service.Get Eliom_parameter.unit) ()

(* Make service available on the client *)
let%client service = ~%service
let%server s, f = Eliom_shared.React.S.create None

let%client action (h, m) =
  ~%f (Some (h, m));
  Lwt.return_unit

let%shared string_of_time = function
  | Some (h, m) ->
      [%i18n Demo.S.you_click_on_time ~h:(string_of_int h) ~m:(string_of_int m)]
  | None -> ""

let%server time_as_string () : string Eliom_shared.React.S.t =
  Eliom_shared.React.S.map [%shared string_of_time] s

let%server time_reactive () = Lwt.return @@ time_as_string ()

let%client time_reactive =
  ~%(Eliom_client.server_function [%json: unit]
       (Os_session.connected_wrapper time_reactive))

(* Name for demo menu *)
let%shared name () = [%i18n Demo.S.timepicker]
(* Class for the page containing this demo (for internal use) *)
let%shared page_class = "os-page-demo-timepicker"

(* Page for this demo *)
let%shared page () =
  let time_picker, _, back_f =
    Ot_time_picker.make ~h24:true ~action:[%client action] ()
  in
  let button =
    Eliom_content.Html.D.button [%i18n Demo.timepicker_back_to_hours]
  in
  ignore
    [%client
      (Lwt.async (fun () ->
           Lwt_js_events.clicks (Eliom_content.Html.To_dom.of_element ~%button)
             (fun _ _ -> ~%back_f (); Lwt.return_unit))
        : _)];
  let%lwt tr = time_reactive () in
  Lwt.return
    [ h1 [%i18n Demo.timepicker]
    ; p [%i18n Demo.timepicker_description]
    ; div [time_picker]
    ; p [Eliom_content.Html.R.txt tr]
    ; div [button] ]
