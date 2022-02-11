
#this is a starlark script to convert a lorawan output hex string to single float variables

load("math.star", "math")

def converter(text):

        d4 = int(text[0:2], base=16)
        d3 = int(text[2:4], base=16)
        d2 = int(text[4:6], base=16)
        d1 = int(text[6:], base=16)

        if (d1 & 128)==128:
                sign=-1
        else:
                sign=1

        exp=(d1<<1)+(d2>>7)
#       mantissa=(((d2 & 127)*(2**16) + d3*(2**8) + d4))/(2**23)
        mantissa=(((d2 & 127)*65536 + d3*256 + d4))/8388608

        result=sign*(1+mantissa)*math.pow(2,(exp-127))
        return result

def apply(metric):
        data = metric.fields.get('data')

        metric.fields["Sensor_Lat"] = converter(data[0:8])
        metric.fields["Sensor_Long"] = converter(data[8:16])
        metric.fields["Sensor_Att"] = converter(data[16:24])
        metric.fields["Sensor_Course"] = converter(data[24:32])
        metric.fields["Sensor_Speed"] = converter(data[32:40])
        metric.fields["Sensor_HDOP"] = converter(data[40:48])
        metric.fields["Sensor_Batt"] = int(data[48:52], base=16)

        return metric
