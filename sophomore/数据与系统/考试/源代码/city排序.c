/*
 $$$$$$\   $$$$$$\  $$\   $$\ $$$$$$$$\ 
$$  __$$\ $$  __$$\ $$ |  $$ |\__$$  __|
$$ /  \__|$$ /  $$ |$$ |  $$ |   $$ |   
$$ |      $$ |  $$ |$$ |  $$ |   $$ |   
$$ |      $$ |  $$ |$$ |  $$ |   $$ |   
$$ |  $$\ $$ $$\$$ |$$ |  $$ |   $$ |   
\$$$$$$  |\$$$$$$ / \$$$$$$  |   $$ |   
 \______/  \___$$$\  \______/    \__|   
               \___|                    
                                        
   ������Ϣ�İ� Ҧ��   Using gbk encoding                             
*/
#include<stdio.h>
#define N 21

void selection_sort(int a[], int len);
void putname(int t);//�������
int main()
{
int a[N]={85131,12292,14312,16605,5911,152629,6344,16310,12759,60423,12232,7134,20257,12514,5386,7440,5326,15303,13271,5757,4382,};
/*char *name[N]={"������","������","�ɶ���","������","������","������","�㰲��","��Ԫ��","��ɽ��","��ɽ��",
"������","üɽ��","������","�ϳ���","�ڽ���","��֦����","������","�Ű���","�˱���","������","�Թ���"};*/
int i;
selection_sort(a, N);
printf("the right sort is :");
for(i=0;i<N;i++)
{   
    putname(a[i]);
    printf("%d<",a[i]);
}
    return 0;
}

void selection_sort(int a[], int len)//ѡ������
{
    int i,j,temp;
    for (i = 0 ; i < len - 1 ; i++) 
    {
        int min = i;// ��¼��Сֵ����һ��Ԫ��Ĭ����С
        for (j = i + 1; j < len; j++)// ����δ�����Ԫ��
        {
            if (a[j] < a[min])// �ҵ�Ŀǰ��Сֵ
            {
                min = j;// ��¼��Сֵ
            }
        }
        if(min != i)
        {
            temp=a[min];// ������������
            a[min]=a[i];
            a[i]=temp;
        }
    }
}
void putname(int t)
{
    switch(t)
    {
        case 85131:printf("�����ݣ�");break;
        case 12292:printf("�����У�");break;
        case 14312:printf("�ɶ��У�");break;
        case 16605:printf("�����У�");break;
        case 5911:printf("�����У�");break;
        case 152629:printf("�����ݣ�");break;
        case 6344:printf("�㰲�У�");break;
        case 16310:printf("��Ԫ��:");break;
        case 12759:printf("��ɽ��:");break;
        case 60423:printf("��ɽ��:");break;
        case 12232:printf("������:");break;
        case 7134:printf("üɽ��:");break;
        case 20257:printf("������:");break;
        case 12514:printf("�ϳ���:");break;
        case 5386:printf("�ڽ���:");break;
        case 7440:printf("��֦����:");break;
        case 5326:printf("������:");break;
        case 15303:printf("�Ű���:");break;
        case 13271:printf("�˱���:");break;
        case 5757:printf("������:");break;
        case 4382:printf("�Թ���:");break;
        default:printf("unknown");break;
    }
}
