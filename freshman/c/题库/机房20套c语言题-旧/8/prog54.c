#include <conio.h>
#include <stdio.h>
#include <stdlib.h>
double fun(int n)
{



}

main()   /*������*/
{   system("cls");
    printf("%f\n",fun(10));
    NONO();
}

NONO( )
{/* ���ڴ˺����ڴ��ļ�������������ݣ����� fun ������
    ������ݣ��ر��ļ��� */
   FILE  *wf;
   wf = fopen("a29.out", "w") ;
   fprintf(wf,"%f\n",fun(10));
   fclose(wf) ;
 }
