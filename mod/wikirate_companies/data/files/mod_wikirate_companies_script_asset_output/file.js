// company_group.js.coffee
(function(){var n,t,i,e,r,o,c,a,u,d;decko.editorContentFunctionMap[".specification-input"]=function(){var i;return"explicit"===c(this)?"explicit":(i=t(this)).data("locked")?i.find("input.d0-card-content").val():n(i)},$(window).ready(function(){return $("body").on("change","._constraint-metric",function(){var n,t,i,e;return e=(n=$(this)).closest("li").find(".card-slot"),t=encodeURIComponent(n.val()),i=e.slotMark()+"?view=value_formgroup&metric="+t,e.reloadSlot(i)}),$("body").on("change","input[name=spec-type]",function(){return a($(this).slot())}),$("body").on("submit",".card-form",function(){if($(this).find(".specification-input").length>0)return $(this).setContentFieldsFromMap(),r(t(this))})}),decko.slotReady(function(n){if(n.find(".specification-input").length>0)return a(n)}),n=function(n){return n.find(".constraint-editor").map(function(){return i($(this))}).get().join("\n")},i=function(n){return[o(n),d(n),u(n),e(n)].join(";|;")},o=function(n){return n.find(".constraint-metric input").val()},d=function(n){return n.find(".constraint-year select").val()},u=function(n){return n.find(".constraint-value input, .constraint-value .constraint-value-fields > select").serialize()},e=function(n){return n.find(".constraint-related-group select").val()},c=function(n){return $(n).find("[name=spec-type]:checked").val()},t=function(n){return $(n).find(".constraint-list-editor")},a=function(n){var i,e;return e=t(n),i=n.find(".RIGHT-company.card-editor"),"explicit"===c(n)?(i.show(),e.hide()):(i.hide(),e.show())},r=function(n){return n.data("locked","true"),n.find(".constraint-editor input, .constraint-editor select").prop("disabled",!0)}}).call(this);