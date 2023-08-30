function result = PretrialDemo(args)

% Begin parameters
Fixed.param1 = 5;
shit = true;
Fixed.param2 = 'argh';
Fixed.enum = 'item1'; % {'item1', 'item2', 'item3'}
Variable.param1 = 8;
% End parameters

eval(args);

result = Fixed.enum;
figure(3);
title(result);

