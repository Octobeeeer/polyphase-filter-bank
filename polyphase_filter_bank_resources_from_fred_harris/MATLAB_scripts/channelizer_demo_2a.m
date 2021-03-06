% channelizer demo 2

% 30 channel synthesis channelizer 1-to-30 up sample

h=sinc(-(4-1/30):1/30:(4-1/30)).*kaiser(239,8)';
hx=h.*exp(j*2*pi*(-119:119)*1/30);
figure(11)
subplot(2,1,1)
plot(-(4-1/30):1/30:(4-1/30),h,'linewidth',2)
grid on
axis([-4 4 -0.3 1.2])
title('Impulse Response, 239-Tap Prototype Nyquist Filter for 30-Path Analysis Channelizer, 8-Taps per Path')
xlabel('Time Index')
ylabel('Amplitude')

subplot(2,1,2)
plot((-0.5:1/2000:0.5-1/2000)*30,fftshift(20*log10(abs(fft(h/sum(h),2000)))),'linewidth',2)
hold on
plot((-0.5:1/2000:0.5-1/2000)*30,fftshift(20*log10(abs(fft(hx/sum(h),2000)))),'linewidth',2)
plot([+0.4 +0.6],[-1 -1]*6.02,'r','linewidth',2)
plot([0.5 0.5],[-12 -0],'r','linewidth',2)
hold off
grid on
axis([-3 3 -100 10])
title('Frequency Response, Prototype Nyquist Filter for 30-Path Analysis Channelizer')
xlabel('Frequency')
ylabel('Log Magnitude (dB)')




h2=reshape([h 0],30,8);
reg2=zeros(30,8);

m=1;  % input index offset
s=1;  % output index

v1=zeros(1,30)';
v2=zeros(1,30)';
v3=zeros(1,30)';
v4=zeros(30,600);

v4(1,:)=exp(+j*2*pi*(0:599)*0.1);
v4(14,:)=exp(-j*2*pi*(0:599)*0.1);
v4(17,:)=exp(+j*2*pi*(0:599)*0.0);
v4(19,:)=exp(+j*2*pi*(0:599)*0.117);
v4(23,:)=exp(-j*2*pi*(0:599)*0.213);



for n=1:length(v4)
    v3=v4(:,n);
    v2=30*ifft(fftshift(v3));
    reg2=[v2 reg2(:,1:7)];
    
    for k=1:30
        v1(k)=reg2(k,:)*h2(k,:)';
    end
    x2(m:m+29)=v1.';    
    m=m+30;
end

figure(12)
for k=1:30
    subplot(5,6,k)
    plot(0:40,real(v4(k,1:41)))
    hold on
    plot(0:40,imag(v4(k,1:41)),'r')
    hold off
    grid on
    axis([2 40 -1.1 1.1])
     if rem(k,6)==1
        ylabel('Amplitude')
    end
    if k>23
        xlabel('Time Index')
    end
    text(0.25,16,['bin (',num2str(k-16),')'])
    text(30,1.3,['bin',num2str(k-16)])
end

figure(13)
ww=kaiser(500,8)';
ww=10*ww/sum(ww);
w2=kaiser(5000,10)';
w2=w2/sum(w2);
subplot(6,1,1)
plot((-0.5:1/5000:0.5-1/5000)*30,fftshift(20*log10(abs(fft(x2(1:5000).*w2)))))
hold on
for k=1:30
    plot([-0.82 -0.5 -0.18 0.18 0.5 0.82]+(-16+k),[-80 -6 0 0 -6 -80],'--r','linewidth',2)
end
 plot([-0.82 -0.5 -0.18 0.18 0.5 0.82]+15,[-80 -6 0 0 -6 -80],'--r','linewidth',2)
hold off
grid on
axis([-15 15 -90 10]);
title('Input Spectrum')
xlabel('Frequency')
ylabel('Log Mag (dB)')

for k=1:30
    subplot(6,6,k+6)
    plot((-0.5:1/500:0.5-1/500)*2,fftshift(20*log10(abs(fft(v4(k,1:500).*ww)))))
    grid on
    axis([-1 1 -90 10])
    if rem(k,6)==1
        ylabel('Log Mag (dB)')
    end
    if k>23
        xlabel('Frequency')
    end
    text(0.25,16,['bin (',num2str(k-16),')'])
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%% repeat channelizer but now with signals with bandwidth
% narrow band signals with BW = 1/2 sampled at 30 

g1=sinc(-5:1/2:5).*kaiser(21,8)'; %Shaping filter, 2-samples per symbol
g1=[g1 0];
xx1=zeros(5,1200);
frq=[-6 -2 1 3 7];

for k=1:5
    xx0=(floor(2*rand(1,600))-0.5)/0.5+j*(floor(2*rand(1,600))-0.5)/0.5;
    reg_a=zeros(1,11);
    m=0;
    for n=1:600
       reg_a=[xx0(n) reg_a(1:10)];
        for nn=1:2
           xx4(k,m+nn)=reg_a*g1(nn:2:22)';
        end     
        m=m+2;
    end
end

h2=reshape([h 0],30,8);
reg2=zeros(30,16);

m=1;  % output index

v1=zeros(1,15)';
v2=zeros(1,30)';
v3=zeros(1,30)';
v4=zeros(30,1200);

v4(7,:)=xx4(1,:);
v4(14,:)=xx4(2,:);
v4(17,:)=2*xx4(3,:);
v4(19,:)=xx4(4,:);
v4(23,:)=xx4(5,:);

flg=0;
for n=1:length(v4)
    v3=v4(:,n);
    v2=2*ifft(fftshift(v3));
    if flg==0;
        flg=1;
    else
        flg=0;
        v2=[v2(16:30);v2(1:15)];
    end
    reg2=[v2 reg2(:,1:15)];
    
    for k=1:15
        tp=reg2(k,1:2:16)*h2(k,:)';
        bt=reg2(k+15,2:2:16)*h2(k+15,:)';
        v1(k)=bt+tp;
    end
    x2(m:m+14)=v1.';    
    m=m+15;
end

figure(13)
subplot(2,1,1)
plot(real(x2(1:1000)))
hold on
plot(imag(x2(1:1000)),'r')
hold off
grid on

ww=kaiser(4096,10)';
ww=10*ww/sum(ww);
subplot(2,1,2)
plot((-0.5:1/4096:0.5-1/4096)*30,fftshift(20*log10(abs(fft(x2(501:4596).*ww)))))
grid on
axis([-15 15 -90 5])