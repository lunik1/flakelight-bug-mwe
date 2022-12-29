# awk script for use with the output of free -b which creates output for a
# waybar memory module showing RAM and swap usage as a pair of filled
# hexagons

BEGIN {
    icons[0] = "󰋙"
    icons[1] = "󰫃"
    icons[2] = "󰫄"
    icons[3] = "󰫅"
    icons[4] = "󰫆"
    icons[5] = "󰫇"
    icons[6] = "󰫈"
    n_icons = length(icons)

    for (i = 0; i < n_icons; i++)
        thresholds[i] = i / (n_icons - 1) * 100
    thresholds[n_icons] = -log(0) # +inf
}

function get_icon(x,    j) {
    if (x < 0 || x > 100) {
        return "󰋖"
    }
    while (x >= thresholds[j]) {
        j++
    }
    return icons[j-1];
}

$1 ~ /^Mem:/ {
    memup = (1 - $7 / $2) * 100;
    memu = ($2 - $7)
};

$1 ~ /^Swap:/ {
    swapup = $3 / $2 * 100;
    swapu = $3
};

END {
    printf "{\"text\":\"%s\",\"tooltip\":\"󰩾 %.2f GiB used (%0.f%)\\n󰯍 %.2f GiB used (%0.f%)\"}",
        (get_icon(memup) get_icon(swapup)),
        (memu / 2 ^ 30),
        memup,
        (swapu / 2 ^ 30),
        swapup
}
