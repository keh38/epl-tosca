fn = 'D:\Data\Tosca\KKC38\Session 12\KKC38-Session12-Run1.txt';
s.dt = show_dt_dist(fn);
s.title = 'The One in the Middle: KKC38-12-Run1';

fn = 'D:\Data\Tosca\KKC35\Session 40\KKC35-Session40-Run1.txt';
s(2).dt = show_dt_dist(fn);
s(2).title = 'Tolstoy: KKC38-40-Run1';

fn = 'D:\Data\Tosca\KKC35\Session 40\KKC35-Session40-Run4.txt';
s(3).dt = show_dt_dist(fn);
s(3).title = 'Tolstoy: KKC38-40-Run4';

fn = 'D:\Data\Tosca\MM09\Session 13\MM09-Session13-Run1.txt';
s(4).dt = show_dt_dist(fn);
s(4).title = 'Tolstoy(?): MM09-13-Run1';

fn = 'D:\Data\Tosca\KKC42\Session 12\KKC42-Session12-Run3.txt';
s(5).dt = show_dt_dist(fn);
s(5).title = 'The One in the Middle: KKC42-12-Run3';

figure
SetFigStyle('work');
figsize([12 6]);

nr = 3;
nc = 2;

for k = 1:length(s),
   subplot(nr,nc,k);
   plot(s(k).dt, 'b.');
   axis tight;
   yaxis(0,40);
   ylabel('DI \DeltaT')
   ylabel('DI \DeltaT (ms)')
   set(gca, 'XTickLabel', '');
   title(s(k).title)
   box off;
end