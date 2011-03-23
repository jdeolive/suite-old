r = Raphael("${container}");
<#assign gut = 20>
var gut = ${gut};
var xo = 25;

var fin = function() {
  this.tags = r.set();
  for (var i = 0, ii = this.y.length; i < ii; i++) {
     if (this.values[i] > 0) {
     this.tags.push(r.g.popup(this.x, this.y[i], this.values[i])
        .insertBefore(this).attr([{fill: "#fff"}, {fill: this.symbols[i].attr("fill")}]));
     }
  }
};

var fout = function () {
    this.tags && this.tags.remove();
}

<#if (xlen > 0)>
var line = r.g.linechart(xo, 0, ${width}, ${height}, ${xdata}, ${timeData}, { 
  axis: "0 0 0 1", axisystep: 5, gutter: gut, smooth: true,  symbol: "o"
});
if (${xlen} < 25) {
  line.hoverColumn(fin, fout);
  line.symbols.attr({r:3});
}
else {
  line.symbols.attr({r:0});
}

r.g.axis(${gut}+xo, ${height}-${gut}, ${width} - 2*${gut}, 0, ${xlen}, ${xsteps}, 0, ${labels});
r.g.text(${width}/9, gut, "Average Request Time (ms)").attr({"text-anchor":"start"});

line = r.g.linechart(xo, ${height}, ${width}, ${height}, ${xdata}, ${thruData}, { 
  axis: "0 0 0 1", axisystep: 5, gutter: gut, smooth: true,  symbol: "o"
});
if (${xlen} < 25) {
  line.hoverColumn(fin, fout);
  line.symbols.attr({r:3});
}
else {
  line.symbols.attr({r:0});
}
r.g.axis(${gut}+xo, 2*${height}-${gut}, ${width} - 2*${gut}, 0, ${xlen}, ${xsteps}, 0, ${labels});
r.g.text(${width}/9, ${height}+gut, "Average Throughput (bytes)").attr({"text-anchor":"start"});

<#else>
  <#assign xlen = 0>
r.g.linechart(xo, 0, ${width}, ${height}, [0], [0], { axis: "0 0 1 1", gutter: gut, smooth: true});

r.g.txtattr.font = "12px 'Fontin Sans', Fontin-Sans, sans-serif";
r.g.text(${width}/2, ${height}/2, "No data");
</#if>


<#assign w = width - 2*gut>
<#assign dx = w / xsteps>

<#list breaks as break>
  <#assign x = gut+10 + dx*break[0] + dx*break[1]/break[2]>
  <#assign y = 270>

r.text(${x}, ${y}, "${break[3]}").attr({"text-anchor":"left", "opacity": "0.75"});
</#list>