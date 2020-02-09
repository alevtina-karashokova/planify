/*
* Copyright © 2019 Alain M. (https://github.com/alainm23/planner)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
* Authored by: Alain M. <alainmh23@gmail.com>
*/

public class Objects.Section : GLib.Object {
    public int64 id { get; set; default = 0; }
    public int64 project_id { get; set; default = 0; }
    public int64 sync_id { get; set; default = 0; }
    public string _name = "";
    public string name {
        get { return _name; }
        set { _name = value.replace ("&", " "); }
    }
    public int item_order { get; set; default = 0; }
    public int collapsed { get; set; default = 1; }
    public int is_todoist { get; set; default = 0; }
    public int is_deleted { get; set; default = 0; }
    public int is_archived { get; set; default = 0; }
    public string date_archived { get; set; default = ""; }
    public string date_added { get; set; default = new GLib.DateTime.now_local ().to_string (); }

    private uint timeout_id = 0;

    public void save () {
        if (timeout_id != 0) {
            Source.remove (timeout_id);
            timeout_id = 0;
        }

        timeout_id = Timeout.add (500, () => {
            Planner.database.update_section (this);
            if (is_todoist == 1) {
                Planner.todoist.update_section (this);
            }

            Source.remove (timeout_id);
            timeout_id = 0;
            return false;
        });
    }

    public void save_local () {
        if (timeout_id != 0) {
            Source.remove (timeout_id);
            timeout_id = 0;
        }

        timeout_id = Timeout.add (1500, () => {
            new Thread<void*> ("save_local_timeout", () => {
                Planner.database.update_section (this);

                return null;
            });

            Source.remove (timeout_id);
            timeout_id = 0;
            return false;
        });
    }

    public string to_json () {
        var builder = new Json.Builder ();
        builder.begin_object ();

        builder.set_member_name ("id");
        builder.add_int_value (this.id);

        builder.set_member_name ("name");
        builder.add_string_value (this.name);

        builder.set_member_name ("project_id");
        if (Planner.database.curTempIds_exists (this.project_id)) {
            builder.add_string_value (Planner.database.get_temp_id (this.project_id));
        } else {
            builder.add_int_value (this.project_id);
        }

        builder.end_object ();

        Json.Generator generator = new Json.Generator ();
        Json.Node root = builder.get_root ();
        generator.set_root (root);

        return generator.to_data (null);
    }

    public void share_text () {

    }

    public void share_markdown () {

    }
}
