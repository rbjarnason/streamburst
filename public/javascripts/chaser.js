/* Script by: www.jtricks.com
 * Version: 20060303
 * Latest version:
 * www.jtricks.com/javascript/navigation/floating.html
 */
var target_x = 0;
var target_y = 10;

var has_inner = typeof(window.innerWidth) == 'number';
var has_element = document.documentElement && document.documentElement.clientWidth;

var fm_id='chaser';
var floating_menu =
    document.getElementById
    ? document.getElementById(fm_id)
    : document.all
      ? document.all[fm_id]
      : document.layers[fm_id];

var fm_shift_x, fm_shift_y, fm_next_x, fm_next_y;

function move_menu()
{
    if (document.layers)
    {
        floating_menu.left = fm_next_x;
        floating_menu.top = fm_next_y;
    }
    else
    {
       /* floating_menu.style.left = fm_next_x + 'px'; */
        floating_menu.style.top = fm_next_y + 'px';
    }
}

function compute_shifts()
{
    fm_shift_x = has_inner
        ? pageXOffset
        : has_element
          ? document.documentElement.scrollLeft
          : document.body.scrollLeft;
    if (target_x < 0)
        fm_shift_x += has_inner
            ? window.innerWidth
            : has_element
              ? document.documentElement.clientWidth
              : document.body.clientWidth;

    fm_shift_y = has_inner
        ? pageYOffset
        : has_element
          ? document.documentElement.scrollTop
          : document.body.scrollTop;
    if (target_y < 0)
        fm_shift_y += has_inner
            ? window.innerHeight
            : has_element
              ? document.documentElement.clientHeight
              : document.body.clientHeight;
}

function float_menu()
{
    var step_x, step_y;

    compute_shifts();

    step_x = (fm_shift_x + target_x - fm_next_x) * .07;
    if (Math.abs(step_x) < .5)
        step_x = fm_shift_x + target_x - fm_next_x;

    step_y = (fm_shift_y + target_y - fm_next_y) * .07;
    if (Math.abs(step_y) < .3)
        step_y = (fm_shift_y + target_y - fm_next_y) * .3;

    if (Math.abs(step_x) > 0 ||
        Math.abs(step_y) > 0)
    {
        fm_next_x += step_x;
        fm_next_y += step_y;
        move_menu();
    }

    setTimeout('float_menu()', 20);
};

compute_shifts();
if (document.layers)
{
    // Netscape 4 cannot perform init move
    // when the page loads.
    fm_next_x = 0;
    fm_next_y = 0;
}
else
{
    fm_next_x = fm_shift_x + target_x;
    fm_next_y = fm_shift_y + target_y;
    move_menu();
}
float_menu();
