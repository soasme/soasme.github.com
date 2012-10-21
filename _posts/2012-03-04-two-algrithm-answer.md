---
layout: post
---

两道面试的算法题
===============

They are shown below:

- 给出随机数列[-1,2,4,-5,0,2,4,6,9,-3,2],其最长单调递增数列是[0,2,4,6,9]，写出算法。


    void get_longest_incr_array(int data[],int len) {

        int current_length = 1;
        int current_base = 0;
        int max_length = 1;
        int max_base = 0;

        for(int i = 1; i < len; i++ ) {
            if(data[i]>data[i-1]) {
                current_length += 1;
                if(current_length > max_length) {
                    max_base = current_base;
                    max_length = current_length;
                }
            } else {
                current_length = 1;
                current_base = i;
            }
        }
        printf("%d, %dn",max_base,max_length); // max_base是数组最长单调递增子序列的起始点，max_length是该序列的长度
    };

    int main(int argc, char *argv[]) {
        int test[14] = {5,4,1,2,3,4,5,6,1,2,5,3,2,1}; // 1,2,3,4,5,6
        get_longest_incr_array(test,14);

        int test2[14] = {0,2,1,2,1,1,3,5,7,9,10,11,12,14}; // 1,3,5,7,9,10,11,12,14
        get_longest_incr_array(test2,14);
        return 0;
    }

- 设有M*N矩阵

```
0,1,0,0,0,0,0,1,0,0
1,1,1,0,1,0,0,0,0,1
0,0,1,0,1,0,0,0,1,1
0,0,0,0,1,0,0,0,0,0
```
规则：有连续1的块算一个大块，例如上述矩阵有4个，求通用解法
【想了很久被面试官提示用递归寻找连续1块，继续想了很久得出最终解法  】


    int search_big_block(int *data,int m, int n,int index_x,int index_y) {
        if ( *(data+index_x*n+index_y) == 0 )
        {
            return 0;
        } else {
            *(data+index_x*n+index_y) = 0; // 顺便置为0 如此递归下次寻找便不会找到这里来了
            if(index_x > 0){
                search_big_block(data,m,n,index_x-1,index_y);
            }
            if(index_x < m){
                search_big_block(data,m,n,index_x+1,index_y);
            }
            if(index_y > 0){
                search_big_block(data,m,n,index_x,index_y-1);
            }
            if(index_y < n){
                search_big_block(data,m,n,index_x,index_y+1);
            }
            return 1;
        }
    }

    int main(int argc, char *argv[])
    {
        int data[] = {
            0,1,0,0,0,0,0,1,0,0,
            1,1,1,0,1,0,0,0,0,1,
            0,0,1,0,1,0,0,0,1,1,
            0,0,0,0,1,0,0,0,0,0
        };

        int control = 0;
        for(int i=0;i < 4;i++) {
            for(int j=0;j < 10;j++) {
                if (search_big_block(data,4,10,i,j))
                {
                    control += 1;
                }
            }
        }
        printf("%d",control);
        return 0;
    }
