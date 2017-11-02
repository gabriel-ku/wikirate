# -*- encoding : utf-8 -*-

class MoveScriptPdfjsHostToCode < Card::Migration
  def up
    ensure_card "script: pdfjs hosts",
                codename: "script_pdfjs_host",
                type_id: Card::CoffeeScriptID
  end
end