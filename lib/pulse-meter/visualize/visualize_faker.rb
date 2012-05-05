class VisualizeFaker
  def self.widget(page_id, widget_id)
    widgets(page_id)[widget_id - 1]
  end

  def self.widgets(page_id)
    widget_data = [
        {
            id: 1,
            title: "Widget 1 on page #{page_id}",
            type: :pie,
            values_title: 'Rabbit Count',
            width: 6,
            interval: 10,
            series: [
                {
                    type: :pie,
                    name: "Rabbit Count",
                    data: [
                        ['Sensor 1', Random.rand(1000)],
                        ['Sensor 2', Random.rand(1000)],
                        ['Sensor 3', Random.rand(1000)]
                    ]
                }
            ]
        },
        {
            id: 2,
            title: "Widget 2 on page #{page_id}",
            type: :spline,
            values_title: 'Croco Count',
            width: 4,
            interval: 10,
            series: [
                {
                    name: 'Sensor 1',
                    data: 10.downto(1).map{|i| [ (Time.now.to_i - i*3600)*1000, Random.rand(100) ]},
                },
                {
                    name: 'Sensor 2',
                    data: 10.downto(1).map{|i| [ (Time.now.to_i - i*3600)*1000, Random.rand(100) ]}
                }
            ]
        },
        {
            id: 3,
            title: "Widget 3 on page #{page_id}",
            type: :line,
            values_title: 'Rhino Count',
            width: 3,
            interval: 10,
            series: [
                {
                    name: 'Sensor 1',
                    data: 10.downto(1).map{|i| [ (Time.now.to_i - i*3600)*1000, Random.rand(100) ]},
                },
                {
                    name: 'Sensor 2',
                    data: 10.downto(1).map{|i| [ (Time.now.to_i - i*3600)*1000, Random.rand(100) ]}
                }
            ]
        },
        {
            id: 4,
            title: "Widget 4 on page #{page_id}",
            type: :spline,
            values_title: 'Lama Count',
            width: 7,
            interval: 10,
            series: [
                {
                    name: 'Sensor 1',
                    data: 10.downto(1).map{|i| [ (Time.now.to_i - i*3600)*1000, Random.rand(100) ]},
                },
                {
                    name: 'Sensor 2',
                    data: 10.downto(1).map{|i| [ (Time.now.to_i - i*3600)*1000, Random.rand(100) ]}
                }
            ]
        }
    ]

  end
end