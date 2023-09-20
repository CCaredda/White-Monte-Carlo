function [z_est, M]=Ray_z(do, f, Zs, Zf, dz)
%This function is for searching image distance of the single lens system 
%Input
%do: working distance (in mm) (distance tissue-lens) ?
%f: focal length (in mm)
%Zs: Start point of search (in mm)
%Zf: End point of search (in mm) 
%dz: resolution of the search (in mm)
%Ouputs
%Z_est: position in z of the image plan behind the lens (in mm) (mm)
%M: ?
    To=[1, do;0,1]; 
    Lf=[1,0;-(1/f),1];
    ro=[0;1]; 
    n=0; 

    
    for z=Zs:dz:Zf 
        n=n+1; 
        Z1(n)=z;
        Ti=[1,z;0,1]; 
        S=Ti*Lf*To;
        %"image" ray coordinate is ri 
        ri=S*ro;
        Ri(n)=ri(1,1); 
    end
    [M, N]=min(abs(Ri));
    z_est=Z1(N);
    

end