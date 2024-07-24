main()
{
    long float f, t, x[4][4], y[4][4];
    long float x1=1.2;
    long float x3, x2=.76;
    int n, a, n1, n2, n3, k9, k6, k8;
    n=0;
    /* x3 is for testing */
    x3 = x1/x2;
    x3 = 9.9999987654321e60;
    printf("M A T R I X   I N V E R S I O N");
    k6=0;
    for(k8=0;;k8++) {
        if(k8==10) break;
/*-slash is at left hand end */
        if(k8<5); else k6++;
        }
    k8=0; while(1) {
        if(k8==10) break;
        k8++;
        }
    for(k8=0; ;k8++) if(k8==10) break;
    k8=0;while(1) {
        k8++;
        if(k8>10) break;
        }

/* this is the real start of the matrix inversion */

    for(k9=0;
             ;
              k9++) {
        a=4;
        n++;
        if(n==1)
                 n=n;
        if(n==2)
                 n=n;
        if(n==3)
                 n=n;
        if(n==4)
                 n=n;
        if(n==5)
                 n=n;
        if(n==6)
                 n=n;
        if(n==7)
                 n=n;
        if(n==8)
                 n=n;
        if(n==9)
                 n=n;
        if(n==10)
                 n=n;
        if(n==50)
                 n=n;
        x[0][0]=0.0;
                    x[0][0]=1.123456789111111111111;
        x[0][0]=1.23456789;x[0][0]=12.3456789;
        printf("\n\n\nRun number is %d",n);
        x[0][0]= 1.;x[0][1]=.04;x[0][2]=.03;x[0][3]=.02;
        x[1][0]= .02;x[1][1]=1.;x[1][2]=.03;x[1][3]=.01;
        x[2][0]= .01;x[2][1]=.01;x[2][2]=1.;x[2][3]=.01;
        x[3][0]=-.02;x[3][1]=.02;x[3][2]=.03;x[3][3]=1.;
        printf("\n\nThe X matrix is");
        for(n1=0;n1<a;n1++) {
            for(n2=0;n2<a;n2++) {
                printf("\nx[%d][%d] is %f",n1,n2,x[n1][n2]);
                }
            }
/* slash is at left hand end */
        for(n1=0;n1<a;n1++) {
            for(n2=0;n2<a;n2++) {
                if(n2==n1)
                           y[n1][n2] = 1;
                           else y[n1][n2] = 0;
                }
            }
        for(n1=0;n1<a;n1++) {
            for(n2=0;n2<a;n2++) {
                if(n2 != n1) {
                    f=x[n2][n1]/x[n1][n1];
                    for(n3=0;n3<a;n3++) {
                        if(n3==n1)
                                   x[n2][n3]=0.0;
                        if(n3 == 412)
                                   x[n2][n3] = 212.0;
                        if(n3>n1)
                                   x[n2][n3] = x[n2][n3]-f*x[n1][n3];
                        if(n3<=n1)
                                   y[n2][n3] = y[n2][n3]-f*y[n1][n3];
                        }
                    }
                }
            }
        for(n1=0;n1<a;n1++) {
            t = x[n1][n1];
            x[n1][n1] = 1.;
            for(n2=0;n2<a;n2++) {
                y[n1][n2] = y[n1][n2] / t;
                }
            }
        printf("\n\ninverse is");
        for(n1=0;n1<a;n1++) {
            for(n2=0;n2<a;n2++) {
                printf("\ny[%d][%d] is %f",n1,n2,y[n1][n2]);
                }
            }
        }
    }
