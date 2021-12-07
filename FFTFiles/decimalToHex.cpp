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
    myfile.open("twiddleFactorsList.txt");
    outputFile.open("twiddleHex.txt");

   if(myfile.is_open() && outputFile.is_open()) {
	std::string tp;
	int count = 0;
        while(getline(myfile, tp)) {
	    bool negative;
	    int integralPart;
	    string wholeValue;

	    count++;

            if (tp.at(0) == '-') { 
		negative = true;
            } else {
		negative = false;
	    }

	    wholeValue = tp;

	    if (wholeValue.at(0) == '1') {
		integralPart = 1;
		wholeValue.replace(0,1,"0");
	    } else {
		integralPart = 0;
	    }

	    string hexValue = "0x0000_";
	
	    if (negative) {
		hexValue = "0x1111_";
	    }

	    if (integralPart == 1) {
		hexValue = "0x0001_";
	    }
		
	    //cout << wholeValue << '\n';

	    double value;
	    double whole_d;
	    int whole;

	    value = std::stod (wholeValue);
	    std::modf(value, &whole_d);
	    whole = static_cast<int>(whole_d);
	    
	    // want constantly multiply by 16, take the integer part, and use that as the hex value
	    for (int i = 0; i < 4; i++) {
		value = value * 16.0;
		value = std::modf(value, &whole_d);
		whole = static_cast<int>(whole_d); 

		std::stringstream stream;

		if (negative && whole != 0) {
		    whole = whole + 16;
		}

		if (whole < 10) {
		   stream << whole;
		} else {
		   switch(whole) {
			case(10):
				stream << "A";
				break;
			case(11):
				stream << "B";
				break;
			case(12):
				stream << "C";
				break;
			case(13):
				stream << "D";
				break;
			case(14):
				stream << "E";
				break;
			case(15):
				stream << "F";
				break;
		   }
		}

		//cout << whole_d << '\n';	

		hexValue.append(stream.str());
	    }
	    //cout << hexValue << '\n';
	    outputFile << hexValue << '\n';
        }
    }

    myfile.close();
    outputFile.close();
}
