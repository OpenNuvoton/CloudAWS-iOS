//
//  MPChartManager.swift
//  CloudAWS
//
//  Created by MS70WPHU on 2021/11/29.
//

import UIKit
import Charts

class MPChartManager: NSObject {
    
    class MPPoint {
        public var name: String? = nil
        public var value: Double? = nil
    }
    
    private var _LineDataSetArray = Array<LineChartDataSet>()
    private var _lineChartView:LineChartView
    private var _LastPonit = MPPoint()
    
    init(lc:LineChartView) {
        
        _lineChartView = lc
        _lineChartView.xAxis.enabled = false
        
        _lineChartView.chartDescription?.text = "Ver:1.0.0"
        let chartData = LineChartData()  //重要 要創建data
        _lineChartView.data = chartData
    }
    
    func getLastValue() -> MPPoint {
        return _LastPonit
    }
    
    func getLineLabelNameArray() -> Array<String> {

        var lineLabelNameArray = Array<String>()
        for lds in _LineDataSetArray {
            lineLabelNameArray.append(lds.label!)
        }

        return lineLabelNameArray
    }
    
    func addChartDataSet(name: String) {
        
        for lds in _LineDataSetArray{
            if (lds.label == name) {
                return
            }
        }
        
        let color = UIColor(red: .random(in: 0...1),green: .random(in: 0...1),blue: .random(in: 0...1), alpha: 1.0)
        
        let lds = LineChartDataSet(entries: [ChartDataEntry](),label: name)
        lds.setCircleColor(color)
        lds.valueColors = [color]
        lds.colors = [color]
        //        lds.valueTextColor = [UIColor.blue]
        lds.lineWidth = 4
//        lds.valueFont.withSize(CGFloat(20f))
        lds.valueFormatter = DefaultValueFormatter(decimals: 2)
        //        lds.setDefaultValueFormatter(new DefaultValueFormatter(digits = 1))
        
        _LineDataSetArray.append(lds)
        _lineChartView.data?.addDataSet(lds)
        //        _lineChartView.invalidate()
        _lineChartView.data?.notifyDataChanged()
        _lineChartView.notifyDataSetChanged()
    }
    
    func addEntry(name: String, value: Double) {
        
        _LastPonit.name = name
        _LastPonit.value = value
        
        let data: ChartData? = _lineChartView.data
        if(data == nil){
            return
        }
        let entry = ChartDataEntry(x: Double(data!.entryCount),y: Double(value))
        
        let dls = data!.getDataSetByLabel(name, ignorecase: false)//根據name找DataSet
        dls?.addEntryOrdered(entry)
        
        _lineChartView.data?.notifyDataChanged()
        _lineChartView.notifyDataSetChanged()
        _lineChartView.setVisibleXRangeMaximum(15)
        _lineChartView.moveViewToX(Double((self._lineChartView.data!.entryCount - 15)))
        
    }
    
    func setDisplayLine(labelName: String) {
        
        if (labelName == "ALL") {
            
            for lds in _LineDataSetArray{
                lds.visible = true
            }
            
            return
        }
        
        
        for lds in _LineDataSetArray{
            lds.visible = lds.label == labelName
        }
        
        _lineChartView.data?.notifyDataChanged()
        _lineChartView.notifyDataSetChanged()
    }
}
