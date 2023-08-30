fn = 'C:\Data\Tosca\Data\AI\ToscaAI_18Aug16_181501.aidi01.bin';

fp = fopen(fn, 'rb', 'b');

yd = read_prepended_2d_array(fp, 'char');
ya = read_prepended_2d_array(fp, 'double');

fclose(fp);

