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
                                        
   ������Ϣ4�� Ҧ��   Using GBK encoding  
   Electronic Information Class four Yao Xin                                
*/
#include<stdio.h>
#include<stdlib.h>
typedef int ElemType;
typedef struct LNode
{
    ElemType data;
    struct LNode *next;
}LNode, *linklist;

linklist creatjp(int n);//����Լɪ��
void runjp(linklist C,int n,int k);//��ʼ�û�

int main()
{
    int n,k;
    linklist C;
    printf("������n=? \n k=?\n");
    scanf("%d %d",&n,&k);
    C = creatjp(n);
    printf("the order is :\n");
    runjp(C,n,k);
    printf("�����������\n");
    getch();
    return 0;
}

linklist creatjp(int n)
{
    LNode* t = NULL,*p;
    for(int i = 0;i<n;i++)
    {
        p = (LNode*)malloc(sizeof(LNode));//����һ�����
        p->data = i + 1;
        if (t)
		{
            p->next = t->next;
			t->next = p;  
            t = t->next;
		}
		else 
        {
			p->next = p;  //ͷ���
            t = p->next;
		}
    }
    return t;
}
void runjp(linklist C,int n,int k)
{
    int i = 0;
	while (n > 0)
	{
		i = (i + 1) % k;
		if (i)
		{
			C = C->next;
		}
		else {
			LNode* p = C->next;
			C->next = p->next;
			printf("%d  ", p->data);
			free(p);
			n--;
		}
	}
}