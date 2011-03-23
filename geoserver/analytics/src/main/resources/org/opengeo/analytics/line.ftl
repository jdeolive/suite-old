r = Raphael("${container}");
<#assign gut = 20>
var gut = ${gut};
var xo = 10;

r.g.text(${width}/9, gut, "# of Requests").attr({"text-anchor":"start"});

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
var line = r.g.linechart(xo, 0, ${width}, ${height}, ${xdata}, ${ydata}, { 
  axis: "0 0 0 1", axisystep: 5, gutter: gut, smooth: true,  symbol: "o", 
  colors: ${colors}
});
if (${xlen} < 25) {
  line.hoverColumn(fin, fout);
  line.symbols.attr({r:3});
}
else {
  line.symbols.attr({r:0});
}
<#else>
  <#assign xlen = 0>
r.g.linechart(xo, 0, ${width}, ${height}, [0], [0], { axis: "0 0 0 1", gutter: gut, smooth: true});

r.g.txtattr.font = "12px 'Fontin Sans', Fontin-Sans, sans-serif";
r.g.text(${width}/2, ${height}/2, "No data");
</#if>

r.g.axis(${gut}+10, ${height}-${gut}, ${width} - 2*${gut}, 0, ${xlen}, ${xsteps}, 0, ${labels});

<#assign w = width - 2*gut>
<#assign dx = w / xsteps>

<#list breaks as break>
  <#assign x = gut+10 + dx*break[0] + dx*break[1]/break[2]>
  <#assign y = 270>

r.text(${x}, ${y}, "${break[3]}").attr({"text-anchor":"left", "opacity": "0.75"});
//r.path("M${x} 280L${x} " + gut).attr({"stroke-opacity": "0.25"});
</#list>
