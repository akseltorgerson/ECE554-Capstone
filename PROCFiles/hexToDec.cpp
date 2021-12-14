#include <iostream>
#include <fstream>
#include <string>
#include <cmath>
#include <iomanip>
using namespace std;

// Driver program to test above function
int main()
{
    ifstream myfile; 
    ofstream outputFile; 
    myfile.open("fftOutputSoftware.txt");
    outputFile.open("fftOutputDec.txt");
    if(myfile.is_open() && outputFile.is_open()) {
        std::string tp;
        unsigned int intValue;
        double doubleValue;
        int count = 0;
        while(getline(myfile, tp)) {
            std::stringstream stream;
            stream << tp;
            intValue = static_cast<unsigned int>(std::stoul(tp,nullptr, 16));
            
            printf("%i", intValue);
            cout << '\n';
            
            /**if (tp.at(0) == 'a' || tp.at(0) == 'b' || tp.at(0) == 'c' || tp.at(0) == 'd' || tp.at(0) == 'e' || tp.at(0) == 'f' || tp.at(0) == '8' || tp.at(0) == '9') {
                intValue = (unsigned int)(~intValue + 1);
            } */
            
            printf("%i", intValue);
            cout << '\n';
            
            
            int newVal = (int)intValue;
            doubleValue = static_cast<double>(newVal);
            
            cout << doubleValue;
            
            cout << '\n' << '\n';
            
            doubleValue = doubleValue / 16.0 / 16.0 / 16.0 / 16.0;
            if (count%2 == 1) {
              if (doubleValue < 0) {
                outputFile << doubleValue << 'i' <<'\n';
              } else{
                outputFile << "+" << doubleValue <<'i'<< '\n';
              }
            } else {
              outputFile << doubleValue;
            }
            count ++;
        }
    }
    myfile.close();
    outputFile.close();
}
