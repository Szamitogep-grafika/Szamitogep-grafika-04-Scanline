/* Fábián Gábor
 * CXNU8T
 */
/*
Készítse el azt az alkalmazást, mely egy megadott (statikusan vagy dinamikusan) szakaszt alapul véve előállít egy – a szakaszt, 
 mint oldalélt tartalmazó – szabályos háromszöget, majd ezt kitölti, végül a háromszög szerint parkettázza a grafikus felületet! 
 A program futásidőben újabb bemenő adattal állítsa elő a megfelelő modellt úgy, hogy az előző nem látszik!
 */

Table table;
boolean closed = true;
boolean dynamic = false;
int bgColor = 204;
boolean startFill = false;

float xA, yA, xB, yB, xC, yC;

void setup() {
    size(640, 480);

    table = new Table();    
    table.addColumn("x");
    table.addColumn("y");
    
    
    TableRow newRow;    
    newRow = table.addRow();
    newRow.setInt("x", 200);
    newRow.setInt("y", 300);
    
    newRow = table.addRow();
    newRow.setInt("x", 350);
    newRow.setInt("y", 350);    
    
    
}

void draw() {
    background(bgColor);
    drawLines(table);

    scanlineFill();
    
    if (table.getRowCount() > 1) {
        parquet(xA, yA, xB, yB, xC, yC);
        parquet(xB, yB, xC, yC, xA, yA);
        //parquet(xC, yC, xA, yA, xB, yB);
        parquet(xC, yC, xB, yB, xA, yA); //<>//
    }
}

void drawLine(float x, float y, float x0, float y0) {
    float m;
    float i, j;

    if (x0 != x) { // nem függőleges
        m = (y0 - y) / (x0 - x);

        if (abs(m) <= 1) {
            j = (x < x0) ? y : y0;
            for (i = (x < x0) ? x : x0; i < ((x > x0) ? x : x0); i++) {
                point(i, j);
                j += m;
            }
        } else {
            i = (y < y0) ? x : x0;
            for (j = (y < y0) ? y : y0; j < ((y > y0) ? y : y0); j++) {
                point(i, j);
                i += 1/m;
            }
        }
    } else {    // függőleges
        for (j = (y < y0) ? y : y0; j < ((y > y0) ? y : y0); j++) {
            point(x, j);
        }
    }
}

void drawLines(Table table) {
    if (table.getRowCount()>1) {
        xA = table.getRow(0).getInt("x");
        yA = table.getRow(0).getInt("y");

        xB = table.getRow(1).getInt("x");
        yB = table.getRow(1).getInt("y");

        xC = (xA + xB + sqrt(3) * (yB - yA) ) / 2;
        yC = (yA + yB + sqrt(3) * (xA - xB) ) / 2;

        drawLine(xB, yB, xA, yA);
        drawLine(xC, yC, xA, yA);
        drawLine(xC, yC, xB, yB);
    }
}

void lineThroughPoint(float m, float x0, float y0) {
    float x = 0;
    float yStart = m*x + y0 - m*x0;
    float yEnd = m*x + y0 - m*x0;

    while (x<width) {
        x++;
        yEnd = m*x + y0 - m*x0;
    }
    drawLine(0, yStart, x, yEnd);
}

void parquet(float x1, float y1, float x2, float y2, float x3, float y3) {    
    float m; //<>//
    
    if (x3 != x2) {
        m = (y3 - y2)*1.0 / (x3 - x2);        
        
        float deltaX;    
        float x, y;        
                
        deltaX = tan((90.0 - atan(m) * 180 / PI) * PI / 180) * abs(y2-y1);
        deltaX = abs(abs(x2-x1) - deltaX);        
        
        x = x1;        
        
        while (x>0) {
            x-=deltaX;
        }
        
        //while (abs((y - height - m * x)/m) < width || abs((y - 0 - m * x)/m) < width) {
        while (x < width) {
            lineThroughPoint(m, x, y1);
            x+=deltaX; //<>//
        }
        
    }
}

void scanlineFill() {
    loadPixels();
    int x1 = 0, x2 = 0;
    for (int y = 1; y < height; y++) {
        for (int x = 1; x < width; x++) {
            if (pixels[y*width+x] != color(bgColor)) {
                if (!startFill) {
                    x1 = x;
                    x2 = x;
                    startFill = true;
                } else {
                    x2 = x;                    
                }
            }            
        } // sor vége
        
        if (x1 == x2 && x1 > 0) {
            startFill = false;            
        }
        
        if (startFill) {
            drawLine(x1,y,x2,y);
            startFill = false;
        }
    } // oszlop vége
}

void mousePressed() {
    // ellenorzi, hogy csak 2 pont legyen!
    if (table.getRowCount() == 2) {
        table.clearRows();
    }

    TableRow newRow = table.addRow();    
    newRow.setInt("x", mouseX);
    newRow.setInt("y", mouseY);
}