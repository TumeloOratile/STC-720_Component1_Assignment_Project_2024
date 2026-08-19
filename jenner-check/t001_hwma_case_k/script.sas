*HWMA control chart;
proc iml;
m = 20;
n = 100;
x = j(n, m, .);

*case k;
lambda = 0.25;
xbar_0 = 0.05;		*randomly chosen;
s2_0 = 2;
xbar_vec = j(1, m, .);

*Simulate a multivariate normal sample X_jk;
call randseed(123);
do j = 1 to m; *loop through m samples;
	do k = 1  to n;	*loop through n obs.;
		x[k,j] = rand("normal", xbar_0, s2_0);
	end;
	*get sample means;
	xbar_vec[j] = x[,j][+]/n;
end;
print x, xbar_vec;

*Calculate HWMA statistics and control limits;
xbar_bar = xbar_0;
result = {};
do j =  1 to m;
	if j = 1 then do;
		hwma = lambda * xbar_vec[j] + (1-lambda) * xbar_bar;
		L = 2.5;
		ucl = xbar_0 + L*sqrt(lambda**2 * (s2_0/n));
		lcl = xbar_0 - L*sqrt(lambda**2 * (s2_0/n));
		cl = xbar_0;
	end;
	else do;
		xbar_bar = (xbar_bar + xbar_vec[j-1])/(j-1);
		hwma = lambda * xbar_vec[j] + (1-lambda) * xbar_bar;
		L = 2.5;
		ucl = xbar_0 + L*sqrt(lambda**2 * (s2_0/n) + (1-lambda)**2 * s2_0/(n*(j-1)));
		lcl = xbar_0 - L*sqrt(lambda**2 * (s2_0/n) + (1-lambda)**2 * s2_0/(n*(j-1)));
		cl = xbar_0;
	end;

	result = result // (j || xbar_vec[j] || xbar_bar || hwma || lcl || ucl || cl || L);
end;
nms = {"t" "jth_xbar" "xbar_bar" "hwma" "lcl" "ucl" "cl" "L"};
print result[colname = nms];

create _data from result [colname = nms];
append from result;
quit;
