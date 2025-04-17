(define-module (nmaupu systems misc polkit)
  #:use-module (guix gexp)
  #:use-module (gnu services)
  #:use-module (gnu services dbus))

(define fprintd-polkit-rule
  (file-union
   "fprintd-polkit-rule"
   `(("share/polkit-1/rules.d/00-fprintd.rules"
      ,(plain-file
        "00-fprintd.rules"
        "polkit.addRule(function(action, subject) {
   if (action.id.indexOf(\"net.reactivated.fprint.\") == 0 || action.id.indexOf(\"net.reactivated.Fprint.\") == 0) {
      polkit.log(\"action=\" + action);
      polkit.log(\"subject=\" + subject);
      return polkit.Result.YES;
   }
});
")))))

(define-public fprintd-polkit-rule-service
  (simple-service 'fprintd-polkit-rule polkit-service-type (list fprintd-polkit-rule)))
